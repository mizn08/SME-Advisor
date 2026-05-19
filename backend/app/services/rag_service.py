"""RAG: vector DB (v3) with BM25 fallback; optional OpenAI generation."""

from __future__ import annotations

from typing import Any

from langchain_community.retrievers import BM25Retriever
from langchain_core.documents import Document
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.services.knowledge_base import build_all_documents

_retriever_cache: dict[int, BM25Retriever] = {}


def _get_bm25(db: Session, sme_id: int) -> BM25Retriever:
    if sme_id not in _retriever_cache:
        docs = build_all_documents(db, sme_id)
        if not docs:
            docs = [Document(page_content="No data loaded for this SME yet.")]
        retriever = BM25Retriever.from_documents(docs)
        retriever.k = 5
        _retriever_cache[sme_id] = retriever
    return _retriever_cache[sme_id]


def invalidate_rag_cache(sme_id: int | None = None) -> None:
    if sme_id is None:
        _retriever_cache.clear()
    else:
        _retriever_cache.pop(sme_id, None)
    if get_settings().USE_VECTOR_RAG:
        from app.services import vector_rag_service

        vector_rag_service.invalidate_vector_cache(sme_id)


def _retrieve(db: Session, sme_id: int, question: str) -> tuple[list[Document], str]:
    settings = get_settings()
    if settings.USE_VECTOR_RAG:
        try:
            from app.services import vector_rag_service

            docs = vector_rag_service.vector_query(db, sme_id, question)
            return docs, "chroma_vector"
        except Exception:
            pass
    retriever = _get_bm25(db, sme_id)
    return retriever.invoke(question), "bm25"


def _template_answer(question: str, docs: list[Document]) -> str:
    if not docs:
        return "I do not have enough indexed data yet. Upload a CSV on the Health tab first."
    bullets = []
    for i, d in enumerate(docs[:4], 1):
        src = d.metadata.get("type", "info")
        bullets.append(f"{i}. [{src}] {d.page_content[:280]}")
    context = "\n".join(bullets)
    return (
        f"Question: {question}\n\n"
        "Here is what I found in your SME Advisor knowledge base:\n\n"
        f"{context}\n\n"
        "Tip: Run the Purchase Simulator for a formal financing recommendation with ML scores."
    )


def _openai_answer(question: str, docs: list[Document]) -> str:
    settings = get_settings()
    if not settings.OPENAI_API_KEY:
        return _template_answer(question, docs)
    try:
        from langchain_openai import ChatOpenAI
        from langchain_core.prompts import ChatPromptTemplate

        context = "\n\n".join(d.page_content for d in docs[:5])
        prompt = ChatPromptTemplate.from_messages(
            [
                (
                    "system",
                    "You are SME Advisor for Malaysian SMEs. Answer using ONLY the context. "
                    "Mention RM amounts when relevant. Be concise and practical.",
                ),
                ("human", "Context:\n{context}\n\nQuestion: {question}"),
            ]
        )
        chain = prompt | ChatOpenAI(model=settings.OPENAI_MODEL, temperature=0.2, api_key=settings.OPENAI_API_KEY)
        msg = chain.invoke({"context": context, "question": question})
        return str(msg.content)
    except Exception as exc:  # noqa: BLE001
        return _template_answer(question, docs) + f"\n\n(OpenAI unavailable: {exc})"


def rag_query(db: Session, sme_id: int, question: str) -> dict[str, Any]:
    docs, retrieval_mode = _retrieve(db, sme_id, question)
    settings = get_settings()
    if settings.OPENAI_API_KEY:
        answer = _openai_answer(question, docs)
        mode = f"{retrieval_mode}+openai"
    else:
        answer = _template_answer(question, docs)
        mode = retrieval_mode

    sources = [{"type": d.metadata.get("type"), "snippet": d.page_content[:200]} for d in docs]
    return {"answer": answer, "sources": sources, "mode": mode}
