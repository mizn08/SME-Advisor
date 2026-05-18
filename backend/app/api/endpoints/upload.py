from __future__ import annotations

import io
from typing import Annotated

import pandas as pd
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.sme import SMEProfile
from app.models.transaction import FinancialTransaction
from app.services import data_processor

router = APIRouter(tags=["upload"])


@router.post("/upload-csv")
async def upload_csv(
    sme_id: Annotated[int, Form()],
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")

    if not file.filename or not file.filename.lower().endswith(".csv"):
        raise HTTPException(400, "Please upload a CSV file.")
    raw_bytes = await file.read()
    try:
        raw = pd.read_csv(io.BytesIO(raw_bytes))
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(400, f"Could not parse CSV: {exc}") from exc

    try:
        df, report = data_processor.clean_csv_dataframe(raw)
    except ValueError as exc:
        raise HTTPException(400, str(exc)) from exc

    db.query(FinancialTransaction).filter(FinancialTransaction.sme_id == sme_id).delete()
    rows = []
    for _, row in df.iterrows():
        rows.append(
            FinancialTransaction(
                sme_id=sme_id,
                txn_date=row["txn_date"],
                amount_rm=float(row["amount_rm"]),
                category=str(row["category"]),
                description=str(row.get("description") or ""),
                is_expense=bool(row["is_expense"]),
            )
        )
    db.bulk_save_objects(rows)

    kpis = data_processor.compute_kpis_from_transactions(df)
    data_processor.persist_snapshot(db, sme_id, kpis)
    db.commit()

    return {
        "sme_id": sme_id,
        "transactions_imported": len(rows),
        "cleaning_report": report,
        "kpis": kpis,
    }
