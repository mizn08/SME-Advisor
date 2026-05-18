from datetime import date
from typing import Any, Optional

from pydantic import BaseModel, Field


class DashboardKPIs(BaseModel):
    current_ratio: float
    days_cash_on_hand: float
    burn_rate_monthly_rm: float
    revenue_mtd_rm: float
    expense_mtd_rm: float
    net_operating_cash_rm: float


class MonthlySeriesPoint(BaseModel):
    month: str
    revenue_rm: float
    expense_rm: float


class DashboardResponse(BaseModel):
    sme_id: int
    business_name: str
    industry: str
    kpis: DashboardKPIs
    monthly_series: list[MonthlySeriesPoint]


class PredictRequest(BaseModel):
    sme_id: int
    purchase_amount: float = Field(gt=0)
    purchase_category: str
    selected_bnpl_plan: Optional[str] = None


class ShapItem(BaseModel):
    feature: str
    value: float
    impact: float
    direction: str


class PredictResponse(BaseModel):
    recommendation_type: str
    product_name: str
    explanation: str
    cash_preserved_rm: float
    additional_cost_rm: float
    confidence: float
    shap_values: list[ShapItem] = []
    ml_probability: float


class GovAidOut(BaseModel):
    id: int
    scheme_name: str
    agency: str
    aid_type: str
    max_amount_rm: Optional[float]
    interest_rate_label: Optional[str]
    tenure_months: Optional[int]
    approval_speed_label: str
    requires_bumiputera: bool
    requires_veteran: bool
    industry_keywords: Optional[str]
    digitalisation_only: bool
    description: Optional[str]


class PredictionHistoryItem(BaseModel):
    id: int
    sme_id: int
    created_at: date
    recommendation_type: str
    product_name: str
    confidence: float
    purchase_amount: float


class PredictionDetailResponse(BaseModel):
    id: int
    sme_id: int
    created_at: str
    recommendation_type: str
    product_name: str
    explanation: str
    cash_preserved_rm: float
    additional_cost_rm: float
    confidence: float
    shap_values: list[ShapItem] = []
    request_payload: dict[str, Any]
