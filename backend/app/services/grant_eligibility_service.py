"""Rule-based grant eligibility (no ML)."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.models.gov_aid import GovFinancialAid
from app.models.sme import SMEProfile


def _revenue_band(annual_rm: float) -> str:
    if annual_rm < 300_000:
        return "micro"
    if annual_rm < 1_500_000:
        return "small"
    if annual_rm < 5_000_000:
        return "medium"
    return "large"


def match_grants(
    db: Session,
    *,
    sme_id: int | None = None,
    bumiputera: bool = False,
    revenue_rm: float = 0,
    sector: str = "",
    ssm_registered: bool = True,
    tech_focus: bool = False,
    export_intent: bool = False,
    veteran: bool = False,
) -> list[dict]:
    sme: SMEProfile | None = None
    if sme_id:
        sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()
    if sme:
        bumiputera = sme.bumiputera_flag
        revenue_rm = revenue_rm or sme.annual_revenue_rm
        sector = sector or sme.industry
        veteran = sme.veteran_flag

    band = _revenue_band(revenue_rm)
    sector_l = sector.lower()
    rows = db.query(GovFinancialAid).all()
    matched: list[dict] = []

    for g in rows:
        reasons: list[str] = []
        if g.requires_bumiputera and not bumiputera:
            continue
        if g.requires_veteran and not veteran:
            continue
        if g.digitalisation_only and not tech_focus and "digital" not in sector_l and "it" not in sector_l:
            continue
        kw = (g.industry_keywords or "").lower()
        if kw and kw.strip() and not any(k.strip() in sector_l for k in kw.split(",") if k.strip()):
            if not tech_focus:
                continue

        name_l = g.scheme_name.lower()
        agency_l = g.agency.lower()
        if "tekun" in name_l or "tekun" in agency_l:
            if band in ("micro", "small"):
                reasons.append("Micro/SME revenue band fits TEKUN micro-financing (Budget 2026 RM2.5B channel).")
        if "mara" in name_l:
            if bumiputera:
                reasons.append("Bumiputera-owned enterprise — MARA working capital schemes.")
        if "mdec" in agency_l or "digital" in name_l:
            if tech_focus or "digital" in sector_l or "it" in sector_l:
                reasons.append("Digital/tech adoption focus — MDEC / digitalisation grants.")
        if "cradle" in name_l or "cip" in name_l:
            if tech_focus:
                reasons.append("Tech commercialisation — Cradle CIP SPRINT style programmes.")
        if "sjpp" in name_l or "guarantee" in name_l:
            if band in ("small", "medium", "large"):
                reasons.append("SJPP guarantee scheme — up to 80% bank financing (≤RM20M per company).")
        if "matrade" in name_l and export_intent:
            reasons.append("Export expansion — MATRADE Market Development Grant (Budget 2026).")
        if not reasons:
            reasons.append("General SME eligibility based on profile filters.")

        matched.append(
            {
                "scheme_id": g.id,
                "scheme_name": g.scheme_name,
                "agency": g.agency,
                "aid_type": g.aid_type,
                "max_amount_rm": g.max_amount_rm,
                "match_reasons": reasons,
                "priority": 1 if g.aid_type == "grant" else 2,
            }
        )

    matched.sort(key=lambda x: (x["priority"], -(x["max_amount_rm"] or 0)))
    return matched
