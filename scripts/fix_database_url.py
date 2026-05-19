#!/usr/bin/env python3
"""Ensure SQLAlchemy-compatible DATABASE_URL (Render gives postgres://)."""
import os
import sys

url = os.environ.get("DATABASE_URL", "")
if url.startswith("postgres://"):
    os.environ["DATABASE_URL"] = url.replace("postgres://", "postgresql+psycopg2://", 1)
    print("Adjusted DATABASE_URL for SQLAlchemy", file=sys.stderr)
