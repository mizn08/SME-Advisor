"""Vector DB RAG (Chroma + embeddings) — v3 upgrade from BM25."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from langchain_core.documents import Document
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.services.knowledge_base import build_all_documents

_collection_cache: dict[int, Any] = {}


def _chroma_dir() -> Path:
    settings = get_settings()
    p = Path(settings.CHROMA_PERSIST_DIR)
    p.mkdir(parents=True, exist_ok=True)
    return p


def _get_store(db: Session, sme_id: int):
    if sme_id in _collection_cache:
        return _collection_cache[sme_id]

    from langchain_chroma import Chroma
    from langchain_community.embeddings import FastEmbedEmbeddings

    docs = build_all_documents(db, sme_id)
    if not docs:
        docs = [Document(page_content="No SME data indexed yet.")]

    embeddings = FastEmbedEmbeddings(model_name="BAAI/bge-small-en-v1.5")
    store = Chroma.from_documents(
        documents=docs,
        embedding=embeddings,
        collection_name=f"sme_{sme_id}",
        persist_directory=str(_chroma_dir() / f"sme_{sme_id}"),
    )
    _collection_cache[sme_id] = store
    return store


def invalidate_vector_cache(sme_id: int | None = None) -> None:
    if sme_id is None:
        _collection_cache.clear()
    else:
        _collection_cache.pop(sme_id, None)


def vector_query(db: Session, sme_id: int, question: str, k: int = 5) -> list[Document]:
    store = _get_store(db, sme_id)
    return store.similarity_search(question, k=k)
