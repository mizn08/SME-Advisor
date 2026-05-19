"""LangChain tools wrapping existing BNPL Advisor services."""

from __future__ import annotations

from typing import Any

from langchain_core.tools import tool
from sqlalchemy.orm import Session

from app.models.sme import SMEProfile
from app.services import data_processor, decision_engine, rag_service


def make_tools(db: Session, sme_id: int) -> list:
    sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()

    @tool
    def get_sme_kpis() -> str:
        """Return current financial KPIs for the SME (cash, burn, ratios)."""
        df = data_processor.load_transactions_df(db, sme_id)
        k = data_processor.compute_kpis_from_transactions(df)
        return (
            f"current_ratio={k['current_ratio']:.2f}, days_cash={k['days_cash_on_hand']:.1f}, "
            f"burn_rm={k['burn_rate_monthly_rm']:,.0f}, net_cash_90d={k['net_operating_cash_rm']:,.0f}"
        )

    @tool
    def run_financing_decision(purchase_amount: float, purchase_category: str) -> str:
        """Run ML+rules engine for BNPL vs credit vs grant recommendation."""
        if not sme:
            return "SME not found"
        df = data_processor.load_transactions_df(db, sme_id)
        kpis = data_processor.compute_kpis_from_transactions(df)
        r = decision_engine.decide(db, sme, kpis, purchase_amount, purchase_category, None)
        return (
            f"{r.recommendation_type}: {r.product_name}. "
            f"Cash preserved RM {r.cash_preserved_rm:,.0f}. "
            f"Confidence {r.confidence:.0%}. {r.explanation}"
        )

    @tool
    def search_knowledge_base(question: str) -> str:
        """RAG search over transactions, products, and government schemes."""
        out = rag_service.rag_query(db, sme_id, question)
        return out["answer"]

    return [get_sme_kpis, run_financing_decision, search_knowledge_base]
