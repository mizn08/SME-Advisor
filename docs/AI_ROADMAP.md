# SME Advisor — full AI roadmap (implemented)

```mermaid
flowchart TB
  subgraph done [Done v1–v2]
    ML[sklearn LR RF XGBoost SHAP]
    RAG[RAG + LangChain agents]
    AWS[AWS deploy path]
  end
  subgraph v3 [v3 — implemented]
    VDB[Vector DB + embeddings]
    UNSUP[Clustering / anomalies]
    BANDIT[Bandit on recommendations]
  end
  subgraph later [Post-APC — implemented stubs]
    RL[RL policy + RLHF]
    CV[Invoice OCR]
    FT[Fine-tuned SME LLM]
  end
  done --> v3 --> later
```

| Layer | Status | Where |
|-------|--------|--------|
| ML ensemble | Done | `ml_pipeline/scripts/train_models.py` |
| Vector RAG | Done | `app/services/vector_rag_service.py` |
| BM25 fallback | Done | `app/services/rag_service.py` |
| KMeans + IsolationForest | Done | `app/services/unsupervised_service.py` |
| UCB bandit | Done | `app/services/bandit_service.py` |
| Q-learning + RLHF log | Done | `app/services/rl_policy_service.py` |
| Invoice OCR | Done | `app/services/ocr_service.py` + Tesseract in Docker |
| Fine-tune stub | Done | `ml_pipeline/scripts/finetune_sme_llm.py` |
| AWS | Done | `deploy/aws/` |
