"""SME financial readiness score (0–100) with letter grade."""

from __future__ import annotations

from typing import Any


def letter_grade(score: int) -> str:
    if score >= 90:
        return "A"
    if score >= 80:
        return "B"
    if score >= 70:
        return "C"
    if score >= 60:
        return "D"
    if score >= 50:
        return "E"
    return "F"


def readiness_label(score: int) -> str:
    if score >= 80:
        return "STRONG"
    if score >= 65:
        return "STABLE"
    if score >= 50:
        return "FAIR"
    return "WATCH"


def compute_health_score(kpis: dict[str, Any], runway_days: float | None, anomaly_count: int) -> dict[str, Any]:
    liquidity = min(float(kpis.get("current_ratio") or 0) / 2.0, 1.0)
    cash = min(float(kpis.get("days_cash_on_hand") or 0) / 180.0, 1.0)
    burn = float(kpis.get("burn_rate_monthly_rm") or 1)
    expense = float(kpis.get("expense_mtd_rm") or 0)
    burn_ok = 1.0 - min(expense / (burn + 1), 0.5) if burn > 0 else 0.5
    runway = min((runway_days or 0) / 180.0, 1.0)
    anomaly_penalty = min(anomaly_count * 0.05, 0.2)

    raw = (0.28 * liquidity + 0.32 * cash + 0.15 * burn_ok + 0.25 * runway - anomaly_penalty) * 100
    score = int(max(0, min(100, round(raw))))
    grade = letter_grade(score)
    return {
        "health_score": score,
        "health_grade": grade,
        "health_label": readiness_label(score),
        "pitch_line": f"SME Readiness Score {score}/100 (Grade {grade}) — like a credit score for financial readiness.",
    }
