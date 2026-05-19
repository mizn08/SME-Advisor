#!/usr/bin/env python3
"""Generate APC2026 project proposal PDF for SME Advisor."""

from __future__ import annotations

from pathlib import Path

from fpdf import FPDF

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "APC2026_SME_Advisor_Proposal.pdf"


class ProposalPDF(FPDF):
    def __init__(self) -> None:
        super().__init__()
        self.set_margins(20, 20, 20)

    def w_content(self) -> float:
        return self.w - self.l_margin - self.r_margin

    def header(self) -> None:
        if self.page_no() > 1:
            self.set_font("Helvetica", "I", 9)
            self.set_text_color(100, 100, 100)
            self.cell(0, 8, "SME Advisor - BNPL Advisor for SMEs (Malaysia) | APC2026", align="L")
            self.ln(4)

    def footer(self) -> None:
        self.set_y(-15)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, f"Page {self.page_no()}", align="C")

    def section_title(self, title: str) -> None:
        self.ln(4)
        self.set_font("Helvetica", "B", 14)
        self.set_text_color(0, 77, 64)
        self.multi_cell(self.w_content(), 8, title)
        self.ln(2)
        self.set_draw_color(0, 121, 107)
        self.set_line_width(0.4)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(4)
        self.set_text_color(0, 0, 0)

    def body(self, text: str) -> None:
        self.set_font("Helvetica", "", 11)
        self.multi_cell(self.w_content(), 6, text)
        self.ln(2)

    def bullet(self, text: str) -> None:
        self.set_font("Helvetica", "", 11)
        self.multi_cell(self.w_content(), 6, f"  -  {text}")


def build() -> None:
    pdf = ProposalPDF()
    pdf.set_auto_page_break(auto=True, margin=20)
    pdf.add_page()

    # Title page
    pdf.set_font("Helvetica", "B", 24)
    pdf.set_text_color(0, 77, 64)
    pdf.ln(40)
    w = pdf.w_content()
    pdf.multi_cell(w, 12, "SME Advisor", align="C")
    pdf.set_font("Helvetica", "", 16)
    pdf.set_text_color(60, 60, 60)
    pdf.multi_cell(w, 10, "BNPL Advisor for Small and Medium Enterprises\n(Malaysia)", align="C")
    pdf.ln(15)
    pdf.set_font("Helvetica", "B", 14)
    pdf.multi_cell(w, 8, "APC 2026 Competition Proposal", align="C")
    pdf.ln(20)
    pdf.set_font("Helvetica", "", 11)
    pdf.set_text_color(0, 0, 0)
    pdf.multi_cell(
        w,
        7,
        "An AI-powered mobile advisory platform that helps Malaysian SME owners "
        "choose between cash payment, consumer BNPL, micro-credit, and government "
        "grants using machine learning and explainable decision support.",
        align="C",
    )
    pdf.ln(25)
    pdf.set_font("Helvetica", "I", 10)
    pdf.multi_cell(w, 6, "Repository: github.com/mizn08/SME-Advisor", align="C")
    pdf.multi_cell(w, 6, "Stack: Flutter | FastAPI | PostgreSQL | scikit-learn / XGBoost", align="C")

    # 1 Executive Summary
    pdf.add_page()
    pdf.section_title("1. Executive Summary")
    pdf.body(
        "SME Advisor is a cross-platform mobile application backed by a REST API and "
        "PostgreSQL database. It addresses a critical gap faced by Malaysian small and "
        "medium enterprise (SME) owners: choosing the most capital-efficient way to fund "
        "business purchases among cash, Buy Now Pay Later (BNPL) products, micro-credit "
        "lines, and government financial aid schemes."
    )
    pdf.body(
        "The system ingests SME transaction data via CSV upload, computes financial health "
        "KPIs, and uses an ensemble machine learning model (Logistic Regression, Random "
        "Forest, XGBoost) combined with a rule-based decision engine to recommend the "
        "optimal financing option. SHAP-style explanations provide transparency for each "
        "recommendation."
    )

    # 2 Problem
    pdf.section_title("2. Problem Statement")
    pdf.body(
        "Malaysian SMEs increasingly encounter diverse financing channels: consumer BNPL "
        "(Atome, Grab PayLater, Shopee), micro-credit from agencies (TEKUN, MARA, Agrobank, "
        "JHEV), B2B credit lines, and digitalisation grants (Geran Digital PMKS MADANI, MDEC). "
        "Owners lack a unified tool to compare total cost, cash-flow impact, and eligibility."
    )
    pdf.bullet("Fragmented products with different interest structures and tenures")
    pdf.bullet("Limited visibility of days cash on hand vs repayment obligations")
    pdf.bullet("Government grants require category and ownership eligibility checks")
    pdf.bullet("No mobile-first advisor tailored to Malaysian SME context")

    # 3 Objectives
    pdf.section_title("3. Project Objectives")
    pdf.bullet("Provide a mobile dashboard of SME financial health KPIs")
    pdf.bullet("Simulate major purchases and recommend BNPL, micro-credit, grant, or cash")
    pdf.bullet("Integrate Malaysian government and agency financing schemes")
    pdf.bullet("Deliver explainable AI recommendations (SHAP-style feature drivers)")
    pdf.bullet("Deploy backend via Docker for reproducible demonstration and judging")

    # 4 Solution
    pdf.section_title("4. Proposed Solution")
    pdf.body(
        "SME Advisor delivers five integrated modules accessible via bottom navigation: "
        "Financial Health (dashboard), Purchase Simulator, AI Advisor (recommendation "
        "results), Government Aid Explorer, and Model Performance (transparency and history)."
    )
    pdf.body(
        "End-to-end flow: (1) Upload CSV transactions, (2) View KPIs and charts, "
        "(3) Enter purchase amount and category, (4) Receive ranked recommendation with "
        "cost and cash preserved estimates, (5) Review history and model metrics."
    )

    # 5 Architecture
    pdf.add_page()
    pdf.section_title("5. System Architecture")
    pdf.body("Three-tier architecture:")
    pdf.bullet("Presentation: Flutter mobile app (Android APK, optional Web/Windows)")
    pdf.bullet("Application: FastAPI REST API with decision engine and ML predictor")
    pdf.bullet("Data: PostgreSQL (sme_profile, transactions, offers, prediction_log)")
    pdf.ln(2)
    pdf.body("Key API endpoints:")
    pdf.bullet("POST /upload-csv - ingest and clean transaction data")
    pdf.bullet("GET /sme/{id}/dashboard - KPIs and monthly time series")
    pdf.bullet("POST /predict - financing recommendation with SHAP values")
    pdf.bullet("GET /gov-aid - government and agency schemes catalogue")
    pdf.bullet("GET /sme/{id}/predictions - recommendation history")

    # 6 ML
    pdf.section_title("6. Machine Learning Methodology")
    pdf.body(
        "Training data comprises synthetic SME scenarios (2,200+ labelled samples) where "
        "label = 1 if external financing improves cash-flow stress. Features include days "
        "cash on hand, current ratio, burn rate, purchase amount, purchase-to-burn ratio, "
        "digitalisation flag, and industry indicators."
    )
    pdf.body(
        "Three classifiers are trained and ensembled by averaging predicted probabilities. "
        "If probability < 0.5, Cash is recommended. Otherwise a rule engine compares BNPL "
        "offers, micro-credit lines, and eligible grants, prioritising digitalisation grants "
        "for qualifying purchases. XGBoost SHAP values (or heuristic fallback) explain top "
        "three drivers in the API and mobile UI."
    )

    # 7 Government
    pdf.section_title("7. Government & Financing Integration")
    pdf.body("Pre-seeded schemes include:")
    pdf.bullet("BNPL: Atome Pay in 3, Grab PayLater, Shopee SPayLater")
    pdf.bullet("Micro-credit: TEKUN Mikro, MARA Niaga, Agrobank Micro, JHEV Vendor Financing")
    pdf.bullet("B2B credit: Funding Societies, UOB BizMoney, Dropee Trade Credit")
    pdf.bullet("Grants: Geran Digital PMKS MADANI, MDEC Digitalisation Grant")
    pdf.bullet("Soft loans: TEKUN Pembiayaan Skim Pemulih, MARA Modal Pusingan")

    # 8 Tech stack
    pdf.add_page()
    pdf.section_title("8. Technology Stack")
    pdf.bullet("Mobile: Flutter, Provider, Dio, fl_chart, SharedPreferences, file_picker")
    pdf.bullet("Backend: FastAPI, SQLAlchemy, Pydantic, pandas, uvicorn")
    pdf.bullet("Database: PostgreSQL 15 (Docker) with full relational schema")
    pdf.bullet("ML: scikit-learn, XGBoost, joblib, optional SHAP")
    pdf.bullet("DevOps: Docker, Docker Compose, Makefile, ngrok for demo exposure")

    # 9 Innovation
    pdf.section_title("9. Innovation & Impact")
    pdf.bullet("First mobile BNPL advisor integrating Malaysian government aid for SMEs")
    pdf.bullet("Hybrid ML + rules: probability gate plus lowest effective-cost selection")
    pdf.bullet("Explainable recommendations improve trust for non-technical owners")
    pdf.bullet("Preserves operating cash while surfacing grant opportunities")
    pdf.bullet("Open-source stack suitable for SMEs and further policy partnerships")

    # 10 Implementation
    pdf.section_title("10. Implementation Status")
    pdf.bullet("Fully functional backend API with Docker deployment")
    pdf.bullet("Flutter mobile app with five screens matching UI specification")
    pdf.bullet("ML models trained and bundled (.pkl) in repository")
    pdf.bullet("Database seed: 3 SMEs, 540 transactions, offers and schemes")
    pdf.bullet("Source code published: github.com/mizn08/SME-Advisor")
    pdf.bullet("Release APK built for Android demonstration")

    # 11 Deployment
    pdf.section_title("11. Deployment & Demonstration")
    pdf.body(
        "Local and competition demo: docker compose up --build exposes API on port 8000. "
        "Public judging access via ngrok tunnel (https://*.ngrok-free.app/docs). "
        "Flutter APK configured with --dart-define=API_BASE for remote API connectivity."
    )

    # 12 Future
    pdf.section_title("12. Future Enhancements")
    pdf.bullet("Cloud VM deployment with HTTPS and fixed domain")
    pdf.bullet("Real bank and BNPL API integrations (with consent)")
    pdf.bullet("Multilingual UI (Bahasa Malaysia)")
    pdf.bullet("Federated learning on anonymised SME cohorts")
    pdf.bullet("SSM / MyDigital ID verification for grant pre-qualification")

    # 13 Conclusion
    pdf.section_title("13. Conclusion")
    pdf.body(
        "SME Advisor demonstrates a viable, explainable, and locally relevant financing "
        "advisory platform for Malaysian SMEs. By combining machine learning, structured "
        "financial data, and government scheme awareness in a mobile-first experience, "
        "the project supports smarter capital decisions and improved cash-flow resilience "
        "for the backbone of Malaysia's economy."
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    pdf.output(str(OUT))
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    build()
