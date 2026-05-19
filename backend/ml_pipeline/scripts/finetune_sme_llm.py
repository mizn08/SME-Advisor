#!/usr/bin/env python3
"""Stub: LoRA fine-tune SME Advisor tone on grant/BNPL Q&A pairs (post-APC).

Requires: pip install peft transformers datasets accelerate
Run after exporting pairs to ml_pipeline/data/sme_qa_pairs.jsonl
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "ml_pipeline" / "data" / "sme_qa_pairs.jsonl"
ADAPTER = ROOT / "data" / "finetune_adapter"


def main() -> None:
    ADAPTER.mkdir(parents=True, exist_ok=True)
    if not DATA.is_file():
        sample = [
            {
                "instruction": "Which grant fits digital equipment?",
                "output": "Consider CGC Digitalisation or MDEC-related schemes if eligible.",
            },
        ]
        DATA.parent.mkdir(parents=True, exist_ok=True)
        with DATA.open("w", encoding="utf-8") as f:
            for row in sample:
                f.write(json.dumps(row) + "\n")
        print(f"Created sample {DATA} — add more rows then install peft and re-run.")

    meta = {
        "status": "stub",
        "adapter_dir": str(ADAPTER),
        "pairs_file": str(DATA),
        "next": "Use HuggingFace PEFT LoRA on microsoft/Phi-3-mini-4k-instruct",
    }
    (ADAPTER / "finetune_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(json.dumps(meta, indent=2))


if __name__ == "__main__":
    main()
