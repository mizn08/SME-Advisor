#!/usr/bin/env python3
"""Train LR, RF, XGBoost and persist joblib models for the API."""

from __future__ import annotations

import json
from pathlib import Path

import joblib
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier

ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = ROOT / "ml_pipeline" / "data" / "ml_training.csv"
MODEL_DIR = ROOT / "ml_pipeline" / "models"
FEATURE_ORDER = [
    "days_cash_on_hand",
    "current_ratio",
    "burn_rate_monthly_rm",
    "purchase_amount",
    "purchase_to_burn",
    "is_digitalisation",
    "is_agri",
    "monthly_net_cash",
]


def main() -> None:
    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    if not DATA_PATH.is_file():
        raise SystemExit(f"Missing {DATA_PATH}. Run generate_synthetic_data.py first.")

    df = pd.read_csv(DATA_PATH)
    X = df[FEATURE_ORDER]
    y = df["label"]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    lr = LogisticRegression(max_iter=10000, class_weight="balanced", random_state=42, solver="lbfgs")
    lr.fit(X_train, y_train)

    rf = RandomForestClassifier(
        n_estimators=200,
        max_depth=12,
        min_samples_leaf=4,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1,
    )
    rf.fit(X_train, y_train)

    xgb = XGBClassifier(
        n_estimators=250,
        max_depth=5,
        learning_rate=0.06,
        subsample=0.9,
        colsample_bytree=0.85,
        eval_metric="logloss",
        random_state=42,
    )
    xgb.fit(X_train, y_train)

    for name, model in (
        ("logistic_regression", lr),
        ("random_forest", rf),
        ("xgboost", xgb),
    ):
        path = MODEL_DIR / f"{name}.pkl"
        joblib.dump(model, path)
        print(f"Saved {path}")

    (MODEL_DIR / "feature_order.json").write_text(json.dumps(FEATURE_ORDER), encoding="utf-8")

    for name, model in (("LR", lr), ("RF", rf), ("XGB", xgb)):
        proba = model.predict_proba(X_test)[:, 1]
        pred = (proba >= 0.5).astype(int)
        acc = accuracy_score(y_test, pred)
        try:
            auc = roc_auc_score(y_test, proba)
        except ValueError:
            auc = float("nan")
        print(f"\n{name} accuracy={acc:.3f} auc={auc:.3f}")
        print(classification_report(y_test, pred, digits=3))


if __name__ == "__main__":
    main()
