"""Invoice / receipt OCR (Tesseract) — post-APC computer-vision path."""

from __future__ import annotations

import io
import re
from typing import Any

import pandas as pd


def extract_invoice_text(image_bytes: bytes) -> dict[str, Any]:
    try:
        from PIL import Image
        import pytesseract
    except ImportError as exc:
        return {
            "text": "",
            "error": f"OCR dependencies missing: {exc}",
            "parsed_rows": [],
        }

    try:
        img = Image.open(io.BytesIO(image_bytes))
        text = pytesseract.image_to_string(img)
    except Exception as exc:  # noqa: BLE001
        return {"text": "", "error": str(exc), "parsed_rows": []}

    rows = _heuristic_parse(text)
    return {"text": text.strip(), "parsed_rows": rows, "engine": "tesseract"}


def _heuristic_parse(text: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    amount_re = re.compile(r"RM\s*([\d,]+\.?\d*)", re.I)
    date_re = re.compile(r"(\d{4}-\d{2}-\d{2}|\d{2}/\d{2}/\d{4})")
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        am = amount_re.search(line)
        dt = date_re.search(line)
        if am:
            amt = float(am.group(1).replace(",", ""))
            rows.append(
                {
                    "txn_date": dt.group(1) if dt else None,
                    "amount_rm": amt,
                    "category": "invoice",
                    "description": line[:120],
                    "is_expense": True,
                }
            )
    return rows[:50]


def rows_to_csv_bytes(rows: list[dict[str, Any]]) -> bytes:
    if not rows:
        return b"txn_date,amount_rm,category,description,is_expense\n"
    df = pd.DataFrame(rows)
    for col in ("txn_date", "amount_rm", "category", "description", "is_expense"):
        if col not in df.columns:
            df[col] = None
    return df.to_csv(index=False).encode("utf-8")
