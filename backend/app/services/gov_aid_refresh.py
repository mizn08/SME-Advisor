"""Refresh government schemes from bundled JSON (simulates live catalog sync)."""

from __future__ import annotations

import json
from pathlib import Path

from sqlalchemy.orm import Session

from app.models.gov_aid import GovFinancialAid

DATA = Path(__file__).resolve().parents[1] / "data" / "malaysia_grants.json"


def refresh_from_json(db: Session) -> dict[str, int]:
    if not DATA.is_file():
        return {"inserted": 0, "error": "missing malaysia_grants.json"}
    rows = json.loads(DATA.read_text(encoding="utf-8"))
    inserted = 0
    for r in rows:
        exists = (
            db.query(GovFinancialAid)
            .filter(GovFinancialAid.scheme_name == r["scheme_name"])
            .first()
        )
        if exists:
            continue
        db.add(
            GovFinancialAid(
                scheme_name=r["scheme_name"],
                agency=r["agency"],
                aid_type=r["aid_type"],
                max_amount_rm=r.get("max_amount_rm"),
                interest_rate_label=r.get("interest_rate_label"),
                tenure_months=r.get("tenure_months"),
                approval_speed_label=r["approval_speed_label"],
                requires_bumiputera=r.get("requires_bumiputera", False),
                requires_veteran=r.get("requires_veteran", False),
                industry_keywords=r.get("industry_keywords"),
                digitalisation_only=r.get("digitalisation_only", False),
                description=r.get("description"),
            )
        )
        inserted += 1
    db.commit()
    return {"inserted": inserted, "total": db.query(GovFinancialAid).count()}
