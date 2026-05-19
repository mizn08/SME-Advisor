"""Unsupervised learning: SME clustering + transaction anomaly detection."""

from __future__ import annotations

from typing import Any

import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
from sqlalchemy.orm import Session

from app.models.sme import SMEProfile
from app.services import data_processor

CLUSTER_LABELS = {
    0: "Growth — healthy cash buffer",
    1: "Stable — moderate burn",
    2: "Tight — low runway, watch burn",
}


def _feature_matrix(db: Session) -> tuple[list[int], np.ndarray]:
    smes = db.query(SMEProfile).order_by(SMEProfile.id).all()
    ids: list[int] = []
    rows: list[list[float]] = []
    for sme in smes:
        df = data_processor.load_transactions_df(db, sme.id)
        k = data_processor.compute_kpis_from_transactions(df)
        ids.append(sme.id)
        rows.append(
            [
                k["current_ratio"],
                k["days_cash_on_hand"],
                k["burn_rate_monthly_rm"],
                k["net_operating_cash_rm"],
                float(sme.annual_revenue_rm or 0),
            ]
        )
    if not rows:
        return [], np.empty((0, 5))
    return ids, np.array(rows, dtype=float)


def compute_clusters(db: Session, n_clusters: int = 3) -> dict[str, Any]:
    ids, X = _feature_matrix(db)
    if len(ids) < 2:
        return {"clusters": [], "method": "kmeans", "n_clusters": n_clusters}

    n_clusters = min(n_clusters, len(ids))
    scaler = StandardScaler()
    Xs = scaler.fit_transform(X)
    labels = KMeans(n_clusters=n_clusters, random_state=42, n_init=10).fit_predict(Xs)

    clusters = []
    for sme_id, label in zip(ids, labels):
        clusters.append(
            {
                "sme_id": sme_id,
                "cluster_id": int(label),
                "cluster_label": CLUSTER_LABELS.get(int(label) % 3, f"Cluster {label}"),
            }
        )
    return {"clusters": clusters, "method": "kmeans", "n_clusters": n_clusters}


def get_sme_cluster(db: Session, sme_id: int) -> dict[str, Any] | None:
    data = compute_clusters(db)
    for c in data["clusters"]:
        if c["sme_id"] == sme_id:
            return c
    return None


def detect_anomalies(db: Session, sme_id: int, contamination: float = 0.08) -> dict[str, Any]:
    df = data_processor.load_transactions_df(db, sme_id)
    if df.empty or len(df) < 8:
        return {"anomalies": [], "method": "isolation_forest", "message": "Need more transactions"}

    work = df.copy()
    work["amount_abs"] = work["amount_rm"].abs()
    work["dow"] = pd.to_datetime(work["txn_date"]).dt.dayofweek
    feats = work[["amount_abs", "dow"]].values
    iso = IsolationForest(contamination=contamination, random_state=42)
    preds = iso.fit_predict(feats)

    anomalies = []
    for i, (_, row) in enumerate(work.iterrows()):
        if preds[i] == -1:
            anomalies.append(
                {
                    "txn_date": str(row["txn_date"]),
                    "category": str(row["category"]),
                    "amount_rm": float(row["amount_rm"]),
                    "is_expense": bool(row["is_expense"]),
                    "score": "outlier",
                }
            )
    return {
        "anomalies": anomalies[:15],
        "method": "isolation_forest",
        "total_flagged": len(anomalies),
    }


def sme_insights(db: Session, sme_id: int) -> dict[str, Any]:
    cluster = get_sme_cluster(db, sme_id)
    anomalies = detect_anomalies(db, sme_id)
    return {
        "sme_id": sme_id,
        "cluster": cluster,
        "anomalies": anomalies,
    }
