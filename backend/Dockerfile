# BNPL Advisor API — production image (backend + bundled ML models)
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/backend \
    ML_MODELS_DIR=/app/backend/app/ml_models

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential curl \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt /app/backend/requirements.txt
COPY backend/requirements-shap.txt /app/backend/requirements-shap.txt

RUN pip install --no-cache-dir -r /app/backend/requirements.txt \
    && pip install --no-cache-dir -r /app/backend/requirements-shap.txt

COPY backend/app /app/backend/app
COPY backend/ml_pipeline /app/backend/ml_pipeline
COPY backend/docker-entrypoint.sh /app/backend/docker-entrypoint.sh
COPY scripts /app/scripts

RUN sed -i 's/\r$//' /app/backend/docker-entrypoint.sh \
    && chmod +x /app/backend/docker-entrypoint.sh \
    && mkdir -p /app/backend/data/uploads

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

ENTRYPOINT ["/app/backend/docker-entrypoint.sh"]
