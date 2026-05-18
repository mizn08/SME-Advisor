"""Seed ~6 months of synthetic financial transactions per SME."""

from __future__ import annotations

import random
from datetime import date, timedelta

from sqlalchemy.orm import Session

from app.models.cash_flow import CashFlowSnapshot
from app.models.sme import SMEProfile
from app.models.transaction import FinancialTransaction
from app.services.data_processor import compute_kpis_from_transactions, load_transactions_df, persist_snapshot

CATEGORIES = [
    ("Supplies", True),
    ("Utilities", True),
    ("Logistics", True),
    ("Sales - Retail", False),
    ("Sales - Wholesale", False),
    ("Digital / Software", True),
    ("Equipment", True),
    ("Marketing", True),
    ("Payroll", True),
]


def seed_six_month_transactions(db: Session) -> int:
    """Insert transactions if none exist. Returns rows inserted."""
    if db.query(FinancialTransaction).first():
        return 0

    smes = db.query(SMEProfile).order_by(SMEProfile.id).all()
    if not smes:
        return 0

    random.seed(42)
    today = date.today()
    start = today - timedelta(days=180)
    day_range = [start + timedelta(days=i) for i in range((today - start).days + 1)]

    rows: list[FinancialTransaction] = []
    for sme in smes:
        scale = {1: 1.0, 2: 1.35, 3: 2.1}.get(sme.id, 1.0)
        for _ in range(180):
            txn_date = random.choice(day_range)
            cat, is_exp = random.choice(CATEGORIES)
            if random.random() < 0.58:
                is_exp = True
            if is_exp:
                amount = round(random.lognormvariate(8.3, 0.42) * scale, 2)
            else:
                amount = round(random.lognormvariate(9.1, 0.38) * scale, 2)
            rows.append(
                FinancialTransaction(
                    sme_id=sme.id,
                    txn_date=txn_date,
                    amount_rm=amount,
                    category=cat,
                    description=f"Seeded txn for {sme.business_name}",
                    is_expense=is_exp,
                )
            )

    db.bulk_save_objects(rows)
    db.flush()

    for sme in smes:
        df = load_transactions_df(db, sme.id)
        kpis = compute_kpis_from_transactions(df)
        persist_snapshot(db, sme.id, kpis)

    db.commit()
    return len(rows)
