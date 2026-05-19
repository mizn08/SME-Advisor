#!/usr/bin/env python3
"""Export bandit feedback as training labels for retraining."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

import pandas as pd
from app.db.session import SessionLocal
from app.models.bandit import BanditFeedback

OUT = ROOT / "ml_pipeline" / "data" / "bandit_labels.csv"


def main() -> None:
    db = SessionLocal()
    rows = db.query(BanditFeedback).all()
    db.close()
    if not rows:
        print("No bandit feedback yet — use app thumbs up/down first.")
        return
    df = pd.DataFrame(
        [
            {
                "sme_id": r.sme_id,
                "arm": r.arm,
                "reward": r.reward,
                "accepted": int(r.accepted),
                "prediction_id": r.prediction_id,
            }
            for r in rows
        ]
    )
    OUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUT, index=False)
    print(f"Wrote {len(df)} rows to {OUT}")


if __name__ == "__main__":
    main()
