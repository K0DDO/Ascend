from __future__ import annotations

import uuid
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.schemas import InterviewSessionResponse, InterviewTurnView
from app.auth.service import AuthService
from app.content.service import ContentService
from app.core.config import Settings
from app.core.errors import AppError
from app.models.ai import AIInterviewSession, AIInterviewTurn, InterviewStatus
from app.models.content import Topic


class AIInterviewService:
    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self.session = session
        self.settings = settings

    async def start(self, *, user_id: UUID, topic_id: UUID, question_count: int) -> InterviewSessionResponse:
        await self._ensure_entitlement(user_id)
        await self._ensure_topic_access(user_id, topic_id)

        turns = await self._build_turns(topic_id, question_count)
        if not turns:
            raise AppError("not_found", "No interview material for this topic", status_code=404)

        interview = AIInterviewSession(
            id=uuid.uuid4(),
            user_id=user_id,
            topic_id=topic_id,
            status=InterviewStatus.IN_PROGRESS,
            current_index=0,
            score=0,
            rubric_json={"version": "v1", "kind": "grounded_card_match"},
        )
        self.session.add(interview)
        await self.session.flush()

        for idx, (question, reference) in enumerate(turns):
            self.session.add(
                AIInterviewTurn(
                    id=uuid.uuid4(),
                    session_id=interview.id,
                    turn_index=idx,
                    question=question,
                    reference_answer=reference,
                )
            )
        await self.session.commit()
        return await self.get(user_id=user_id, session_id=interview.id)

    async def answer(self, *, user_id: UUID, session_id: UUID, answer: str) -> InterviewSessionResponse:
        interview = await self._get_user_session(user_id, session_id)
        if interview.status == InterviewStatus.COMPLETED:
            return await self.get(user_id=user_id, session_id=session_id)

        turns = await self._turns_for_session(session_id)
        if interview.current_index >= len(turns):
            interview.status = InterviewStatus.COMPLETED
            await self.session.commit()
            return await self.get(user_id=user_id, session_id=session_id)

        turn = turns[interview.current_index]
        turn.user_answer = answer
        score, feedback = self._score_turn(answer, turn.reference_answer)
        turn.score = score
        turn.feedback = feedback

        interview.current_index += 1
        interview.score = self._aggregate_score(turns)
        if interview.current_index >= len(turns):
            interview.status = InterviewStatus.COMPLETED

        await self.session.commit()
        return await self.get(user_id=user_id, session_id=session_id)

    async def get(self, *, user_id: UUID, session_id: UUID) -> InterviewSessionResponse:
        interview = await self._get_user_session(user_id, session_id)
        turns = await self._turns_for_session(session_id)
        next_question = None
        if interview.current_index < len(turns):
            next_question = turns[interview.current_index].question

        return InterviewSessionResponse(
            session_id=interview.id,
            topic_id=interview.topic_id,
            status=interview.status.value,
            current_index=interview.current_index,
            total_questions=len(turns),
            score=interview.score,
            next_question=next_question,
            turns=[
                InterviewTurnView(
                    turn_index=t.turn_index,
                    question=t.question,
                    user_answer=t.user_answer,
                    score=t.score,
                    feedback=t.feedback,
                )
                for t in turns
            ],
            created_at=interview.created_at,
        )

    async def _ensure_entitlement(self, user_id: UUID) -> None:
        entitlements = await AuthService(self.session, self.settings).get_entitlements(user_id)
        keys = {item.key for item in entitlements.features}
        if "ai_interview" not in keys:
            raise AppError("forbidden", "AI interview entitlement required", status_code=403)

    async def _ensure_topic_access(self, user_id: UUID, topic_id: UUID) -> None:
        await ContentService(self.session, self.settings).get_topic(topic_id, user_id)

    async def _build_turns(self, topic_id: UUID, question_count: int) -> list[tuple[str, str]]:
        topic = await self.session.scalar(select(Topic).where(Topic.id == topic_id))
        title = topic.title if topic else "Topic"

        # Use card fronts/backs as grounded source
        from app.models.content import Card, CardVersion, CardStatus

        card_query = (
            select(CardVersion.front, CardVersion.back)
            .join(Card, Card.id == CardVersion.card_id)
            .where(
                Card.topic_id == topic_id,
                Card.status == CardStatus.PUBLISHED,
                Card.deleted_at.is_(None),
                CardVersion.published_at.is_not(None),
            )
            .limit(question_count)
        )
        rows = (await self.session.execute(card_query)).all()
        turns: list[tuple[str, str]] = []
        for front, back in rows:
            q = (front or {}).get("text") or f"Explain core concept from {title}"
            ref = (back or {}).get("text") or "Structured explanation with key terms."
            turns.append((str(q), str(ref)))
        return turns

    async def _get_user_session(self, user_id: UUID, session_id: UUID) -> AIInterviewSession:
        session = await self.session.scalar(
            select(AIInterviewSession).where(
                AIInterviewSession.id == session_id,
                AIInterviewSession.user_id == user_id,
            )
        )
        if session is None:
            raise AppError("not_found", "Interview session not found", status_code=404)
        return session

    async def _turns_for_session(self, session_id: UUID) -> list[AIInterviewTurn]:
        result = await self.session.execute(
            select(AIInterviewTurn).where(AIInterviewTurn.session_id == session_id).order_by(AIInterviewTurn.turn_index)
        )
        return result.scalars().all()

    @staticmethod
    def _score_turn(answer: str, reference: str) -> tuple[float, str]:
        answer_words = {w.strip(".,:;!?()[]{}").lower() for w in answer.split() if w.strip()}
        ref_words = {w.strip(".,:;!?()[]{}").lower() for w in reference.split() if w.strip()}
        if not ref_words:
            return 0.5, "Answer received. Limited reference context."
        overlap = len(answer_words & ref_words)
        ratio = overlap / max(1, min(len(ref_words), 25))
        score = max(0.0, min(1.0, ratio))
        if score >= 0.75:
            feedback = "Strong grounded answer with key concepts covered."
        elif score >= 0.45:
            feedback = "Decent answer. Add more precise terminology from the topic."
        else:
            feedback = "Weak alignment with expected concepts. Review source cards and retry."
        return score, feedback

    @staticmethod
    def _aggregate_score(turns: list[AIInterviewTurn]) -> float:
        scored = [t.score for t in turns if t.score is not None]
        if not scored:
            return 0.0
        return float(sum(scored) / len(scored))
