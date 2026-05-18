from sqlalchemy import Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class BNPLOffer(Base):
    __tablename__ = "bnpl_offer"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    provider: Mapped[str] = mapped_column(String(128), nullable=False)
    max_amount_rm: Mapped[float] = mapped_column(Float, default=50000.0)
    max_tenure_months: Mapped[int] = mapped_column(Integer, default=12)
    interest_free_days: Mapped[int] = mapped_column(Integer, default=0)
    effective_monthly_rate_pct: Mapped[float] = mapped_column(Float, default=0.0)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
