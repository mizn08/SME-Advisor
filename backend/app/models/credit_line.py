from sqlalchemy import Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class CreditLineOffer(Base):
    __tablename__ = "credit_line_offer"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    provider: Mapped[str] = mapped_column(String(128), nullable=False)
    product_type: Mapped[str] = mapped_column(String(64), default="micro_credit")
    max_amount_rm: Mapped[float] = mapped_column(Float, nullable=False)
    annual_interest_rate_pct: Mapped[float] = mapped_column(Float, nullable=False)
    max_tenure_months: Mapped[int] = mapped_column(Integer, default=36)
    approval_speed_days: Mapped[int] = mapped_column(Integer, default=14)
    eligibility_summary: Mapped[str | None] = mapped_column(Text, nullable=True)
