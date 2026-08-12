from __future__ import annotations

import re
import uuid
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.schemas import (
    InterviewSessionResponse,
    InterviewSummary,
    InterviewTurnView,
    MistakeItemView,
    MistakeListResponse,
    RubricScores,
)
from app.auth.service import AuthService
from app.content.service import ContentService
from app.core.config import Settings
from app.core.errors import AppError
from app.models.ai import AIMistakeItem, AIInterviewSession, AIInterviewTurn, InterviewStatus
from app.models.content import Card, CardStatus, CardVersion, Topic

MISTAKE_THRESHOLD = 0.6
RUBRIC_DIMENSIONS = ("clarity", "correctness", "completeness", "terminology")


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

        for idx, (question, reference, card_id) in enumerate(turns):
            self.session.add(
                AIInterviewTurn(
                    id=uuid.uuid4(),
                    session_id=interview.id,
                    turn_index=idx,
                    card_id=card_id,
                    question=question,
                    reference_answer=reference,
                    rubric_json={},
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
            await self._finalize_session(interview, turns)
            await self.session.commit()
            return await self.get(user_id=user_id, session_id=session_id)

        turn = turns[interview.current_index]
        turn.user_answer = answer
        score, feedback, rubric = self._score_turn(answer, turn.reference_answer)
        turn.score = score
        turn.feedback = feedback
        turn.rubric_json = rubric.model_dump()

        if score < MISTAKE_THRESHOLD:
            await self._record_mistake(
                user_id=user_id,
                session=interview,
                turn=turn,
                answer=answer,
                score=score,
            )

        interview.current_index += 1
        interview.score = self._aggregate_score(turns)
        if interview.current_index >= len(turns):
            interview.status = InterviewStatus.COMPLETED
            await self._finalize_session(interview, turns)

        await self.session.commit()
        return await self.get(user_id=user_id, session_id=session_id)

    async def list_mistakes(self, *, user_id: UUID, session_id: UUID | None = None) -> MistakeListResponse:
        stmt = select(AIMistakeItem).where(AIMistakeItem.user_id == user_id).order_by(AIMistakeItem.created_at.desc())
        if session_id is not None:
            stmt = stmt.where(AIMistakeItem.session_id == session_id)
        rows = (await self.session.execute(stmt)).scalars().all()
        return MistakeListResponse(
            items=[
                MistakeItemView(
                    id=item.id,
                    session_id=item.session_id,
                    turn_id=item.turn_id,
                    card_id=item.card_id,
                    topic_id=item.topic_id,
                    prompt=item.prompt,
                    expected_hint=item.expected_hint,
                    user_answer=item.user_answer,
                    score=item.score,
                    created_at=item.created_at,
                )
                for item in rows
            ]
        )

    async def get(self, *, user_id: UUID, session_id: UUID) -> InterviewSessionResponse:
        interview = await self._get_user_session(user_id, session_id)
        turns = await self._turns_for_session(session_id)
        next_question = None
        if interview.current_index < len(turns):
            next_question = turns[interview.current_index].question

        summary = None
        if interview.status == InterviewStatus.COMPLETED:
            summary = self._build_summary(interview, turns)

        return InterviewSessionResponse(
            session_id=interview.id,
            topic_id=interview.topic_id,
            status=interview.status.value,
            current_index=interview.current_index,
            total_questions=len(turns),
            score=interview.score,
            next_question=next_question,
            turns=[self._turn_view(t) for t in turns],
            summary=summary,
            created_at=interview.created_at,
        )

    async def _ensure_entitlement(self, user_id: UUID) -> None:
        entitlements = await AuthService(self.session, self.settings).get_entitlements(user_id)
        keys = {item.key for item in entitlements.features}
        if "ai_interview" not in keys:
            raise AppError("forbidden", "AI interview entitlement required", status_code=403)

    async def _ensure_topic_access(self, user_id: UUID, topic_id: UUID) -> None:
        await ContentService(self.session, self.settings).get_topic(topic_id, user_id)

    async def _build_turns(self, topic_id: UUID, question_count: int) -> list[tuple[str, str, UUID | None]]:
        topic = await self.session.scalar(select(Topic).where(Topic.id == topic_id))
        title = topic.title if topic else "Topic"

        card_query = (
            select(Card.id, CardVersion.front, CardVersion.back)
            .join(CardVersion, Card.id == CardVersion.card_id)
            .where(
                Card.topic_id == topic_id,
                Card.status == CardStatus.PUBLISHED,
                Card.deleted_at.is_(None),
                CardVersion.published_at.is_not(None),
            )
            .limit(question_count)
        )
        rows = (await self.session.execute(card_query)).all()
        turns: list[tuple[str, str, UUID | None]] = []
        for card_id, front, back in rows:
            q = (front or {}).get("text") or f"Explain core concept from {title}"
            ref = (back or {}).get("text") or "Structured explanation with key terms."
            turns.append((str(q), str(ref), card_id))
        return turns

    async def _record_mistake(
        self,
        *,
        user_id: UUID,
        session: AIInterviewSession,
        turn: AIInterviewTurn,
        answer: str,
        score: float,
    ) -> None:
        hint = turn.reference_answer[:240] + ("..." if len(turn.reference_answer) > 240 else "")
        self.session.add(
            AIMistakeItem(
                id=uuid.uuid4(),
                user_id=user_id,
                session_id=session.id,
                turn_id=turn.id,
                card_id=turn.card_id,
                topic_id=session.topic_id,
                prompt=turn.question,
                expected_hint=hint,
                user_answer=answer,
                score=score,
            )
        )

    async def _finalize_session(self, interview: AIInterviewSession, turns: list[AIInterviewTurn]) -> None:
        summary = self._build_summary(interview, turns)
        mistake_rows = (
            await self.session.scalars(select(AIMistakeItem.id).where(AIMistakeItem.session_id == interview.id))
        ).all()
        mistake_count = len(mistake_rows)
        interview.rubric_json = {
            **(interview.rubric_json or {}),
            "confidence_band": summary.confidence_band,
            "dimension_averages": {
                dim: self._dimension_average(turns, dim) for dim in RUBRIC_DIMENSIONS
            },
            "mistake_count": mistake_count,
        }
        summary.mistake_count = mistake_count

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
    def _turn_view(turn: AIInterviewTurn) -> InterviewTurnView:
        rubric = None
        if turn.rubric_json:
            rubric = RubricScores(**turn.rubric_json)
        return InterviewTurnView(
            turn_index=turn.turn_index,
            question=turn.question,
            user_answer=turn.user_answer,
            score=turn.score,
            feedback=turn.feedback,
            rubric=rubric,
            card_id=turn.card_id,
        )

    @staticmethod
    def _tokenize(text: str) -> set[str]:
        return {w.strip(".,:;!?()[]{}\"'").lower() for w in re.split(r"\s+", text) if w.strip()}

    @classmethod
    def _score_turn(cls, answer: str, reference: str) -> tuple[float, str, RubricScores]:
        answer_words = cls._tokenize(answer)
        ref_words = cls._tokenize(reference)
        overlap = len(answer_words & ref_words)
        ref_size = max(1, min(len(ref_words), 25))
        overlap_ratio = overlap / ref_size

        answer_len = len(answer.split())
        clarity = max(0.0, min(1.0, 0.35 + min(answer_len, 80) / 120))
        correctness = max(0.0, min(1.0, overlap_ratio))
        completeness = max(0.0, min(1.0, overlap_ratio * 0.7 + min(answer_len, 40) / 60 * 0.3))
        long_ref_terms = {w for w in ref_words if len(w) >= 5}
        term_hits = len(answer_words & long_ref_terms)
        terminology = max(0.0, min(1.0, term_hits / max(1, min(len(long_ref_terms), 8))))

        rubric = RubricScores(
            clarity=round(clarity, 3),
            correctness=round(correctness, 3),
            completeness=round(completeness, 3),
            terminology=round(terminology, 3),
        )
        score = round(
            (rubric.clarity * 0.15 + rubric.correctness * 0.35 + rubric.completeness * 0.3 + rubric.terminology * 0.2),
            3,
        )

        if score >= 0.75:
            feedback = "Strong grounded answer with key concepts covered."
        elif score >= 0.45:
            feedback = "Decent answer. Add more precise terminology from the topic."
        else:
            feedback = "Weak alignment with expected concepts. Review source cards and retry."
        return score, feedback, rubric

    @staticmethod
    def _aggregate_score(turns: list[AIInterviewTurn]) -> float:
        scored = [t.score for t in turns if t.score is not None]
        if not scored:
            return 0.0
        return round(float(sum(scored) / len(scored)), 3)

    @classmethod
    def _dimension_average(cls, turns: list[AIInterviewTurn], dimension: str) -> float:
        values = [t.rubric_json.get(dimension) for t in turns if t.rubric_json and t.rubric_json.get(dimension) is not None]
        if not values:
            return 0.0
        return round(sum(values) / len(values), 3)

    @classmethod
    def _build_summary(cls, interview: AIInterviewSession, turns: list[AIInterviewTurn]) -> InterviewSummary:
        averages = {dim: cls._dimension_average(turns, dim) for dim in RUBRIC_DIMENSIONS}
        strong = [dim for dim, val in averages.items() if val >= 0.7]
        weak = [dim for dim, val in averages.items() if val < 0.5]
        score = interview.score
        if score >= 0.8:
            band = "high"
        elif score >= 0.55:
            band = "medium"
        else:
            band = "low"
        mistake_count = int((interview.rubric_json or {}).get("mistake_count", 0))
        return InterviewSummary(
            average_score=score,
            confidence_band=band,
            strong_dimensions=strong,
            weak_dimensions=weak,
            mistake_count=mistake_count,
        )
