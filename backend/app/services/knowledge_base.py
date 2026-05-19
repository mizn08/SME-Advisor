"""Build LangChain documents from SME DB for RAG retrieval."""

from __future__ import annotations

from langchain_core.documents import Document
from sqlalchemy.orm import Session

from app.models.bnpl import BNPLOffer
from app.models.credit_line import CreditLineOffer
from app.models.gov_aid import GovFinancialAid
from app.models.sme import SMEProfile
from app.models.transaction import FinancialTransaction
from app.services import data_processor


def build_sme_documents(db: Session, sme_id: int) -> list[Document]:
    sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()
    if not sme:
        return []

    df = data_processor.load_transactions_df(db, sme_id)
    kpis = data_processor.compute_kpis_from_transactions(df)
    docs: list[Document] = [
        Document(
            page_content=(
                f"SME profile: {sme.business_name}, industry {sme.industry}, "
                f"annual revenue RM {sme.annual_revenue_rm:,.0f}, "
                f"bumiputera={sme.bumiputera_flag}, veteran={sme.veteran_flag}."
            ),
            metadata={"type": "profile", "sme_id": sme_id},
        ),
        Document(
            page_content=(
                f"Financial KPIs: current ratio {kpis['current_ratio']:.2f}, "
                f"days cash on hand {kpis['days_cash_on_hand']:.1f}, "
                f"monthly burn RM {kpis['burn_rate_monthly_rm']:,.2f}, "
                f"net operating cash (90d) RM {kpis['net_operating_cash_rm']:,.2f}."
            ),
            metadata={"type": "kpi", "sme_id": sme_id},
        ),
    ]

    if not df.empty:
        recent = df.tail(15)
        lines = []
        for _, row in recent.iterrows():
            kind = "expense" if row["is_expense"] else "income"
            lines.append(f"{row['txn_date']} {kind} {row['category']} RM {row['amount_rm']:,.2f}")
        docs.append(
            Document(
                page_content="Recent transactions:\n" + "\n".join(lines),
                metadata={"type": "transactions", "sme_id": sme_id},
            )
        )
    return docs


def build_catalog_documents(db: Session) -> list[Document]:
    docs: list[Document] = []
    for g in db.query(GovFinancialAid).all():
        docs.append(
            Document(
                page_content=(
                    f"Government scheme: {g.scheme_name} by {g.agency}. Type {g.aid_type}. "
                    f"Max RM {g.max_amount_rm}. Rate: {g.interest_rate_label}. "
                    f"Speed: {g.approval_speed_label}. Digital only: {g.digitalisation_only}. "
                    f"Bumiputera required: {g.requires_bumiputera}. {g.description or ''}"
                ),
                metadata={"type": "gov_aid", "scheme": g.scheme_name},
            )
        )
    for b in db.query(BNPLOffer).all():
        docs.append(
            Document(
                page_content=(
                    f"BNPL: {b.name} by {b.provider}. Max RM {b.max_amount_rm:,.0f}, "
                    f"tenure {b.max_tenure_months} months, monthly rate {b.effective_monthly_rate_pct}%."
                ),
                metadata={"type": "bnpl", "product": b.name},
            )
        )
    for c in db.query(CreditLineOffer).all():
        docs.append(
            Document(
                page_content=(
                    f"Micro-credit: {c.name} by {c.provider}. Max RM {c.max_amount_rm:,.0f}, "
                    f"APR {c.annual_interest_rate_pct}%, tenure up to {c.max_tenure_months} months."
                ),
                metadata={"type": "credit", "product": c.name},
            )
        )
    return docs


def build_all_documents(db: Session, sme_id: int) -> list[Document]:
    return build_catalog_documents(db) + build_sme_documents(db, sme_id)
