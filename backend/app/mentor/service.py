from __future__ import annotations

import uuid
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.service import AuthService
from app.core.config import Settings
from app.core.errors import AppError
from app.mentor.schemas import (
    AssignmentCreateRequest,
    AssignmentView,
    MentorLinkView,
    MentorProgressSnapshot,
    MentorStudentView,
)
from app.models.mentor import MentorAssignment, MentorLink
from app.models.user import RoleName, User
from app.progress.service import ProgressService


class MentorService:
    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self.session = session
        self.settings = settings

    async def link_student(self, *, mentor: User, student_user_id: UUID) -> MentorLinkView:
        await self._ensure_mentor_access(mentor)
        if mentor.id == student_user_id:
            raise AppError("invalid_request", "Cannot link yourself as student", status_code=400)

        student = await self.session.get(User, student_user_id)
        if student is None or student.deleted_at is not None:
            raise AppError("not_found", "Student not found", status_code=404)

        existing = await self.session.scalar(
            select(MentorLink).where(
                MentorLink.mentor_user_id == mentor.id,
                MentorLink.student_user_id == student_user_id,
            )
        )
        if existing:
            return self._link_view(existing)

        link = MentorLink(
            id=uuid.uuid4(),
            mentor_user_id=mentor.id,
            student_user_id=student_user_id,
            status="active",
        )
        self.session.add(link)
        await self.session.commit()
        return self._link_view(link)

    async def list_students(self, *, mentor: User) -> list[MentorStudentView]:
        await self._ensure_mentor_access(mentor)
        rows = (
            await self.session.execute(
                select(MentorLink, User)
                .join(User, User.id == MentorLink.student_user_id)
                .where(MentorLink.mentor_user_id == mentor.id, MentorLink.status == "active")
            )
        ).all()
        return [
            MentorStudentView(user_id=user.id, display_name=user.display_name, link_id=link.id)
            for link, user in rows
        ]

    async def student_progress(self, *, mentor: User, student_user_id: UUID) -> MentorProgressSnapshot:
        await self._ensure_mentor_access(mentor)
        await self._ensure_link(mentor.id, student_user_id)
        overview = await ProgressService(self.session).overview(student_user_id)
        return MentorProgressSnapshot(
            student_user_id=student_user_id,
            total_reviews=overview.total_reviews,
            know_rate=overview.know_rate,
            readiness=overview.readiness,
        )

    async def create_assignment(self, *, mentor: User, payload: AssignmentCreateRequest) -> AssignmentView:
        await self._ensure_mentor_access(mentor)
        await self._ensure_link(mentor.id, payload.student_user_id)
        assignment = MentorAssignment(
            id=uuid.uuid4(),
            mentor_user_id=mentor.id,
            student_user_id=payload.student_user_id,
            topic_id=payload.topic_id,
            title=payload.title,
            note=payload.note,
            due_at=payload.due_at,
            status="open",
        )
        self.session.add(assignment)
        await self.session.commit()
        return self._assignment_view(assignment)

    async def list_assignments_for_student(self, *, student: User) -> list[AssignmentView]:
        rows = (
            await self.session.scalars(
                select(MentorAssignment)
                .where(MentorAssignment.student_user_id == student.id)
                .order_by(MentorAssignment.created_at.desc())
            )
        ).all()
        return [self._assignment_view(row) for row in rows]

    async def list_assignments_for_mentor(self, *, mentor: User) -> list[AssignmentView]:
        await self._ensure_mentor_access(mentor)
        rows = (
            await self.session.scalars(
                select(MentorAssignment)
                .where(MentorAssignment.mentor_user_id == mentor.id)
                .order_by(MentorAssignment.created_at.desc())
            )
        ).all()
        return [self._assignment_view(row) for row in rows]

    async def add_assignment_comment(self, *, mentor: User, assignment_id: UUID, note: str) -> AssignmentView:
        await self._ensure_mentor_access(mentor)
        assignment = await self.session.get(MentorAssignment, assignment_id)
        if assignment is None or assignment.mentor_user_id != mentor.id:
            raise AppError("not_found", "Assignment not found", status_code=404)
        suffix = f"\n\n[Mentor comment]\n{note.strip()}"
        assignment.note = (assignment.note or "").strip() + suffix
        await self.session.commit()
        return self._assignment_view(assignment)

    async def _ensure_mentor_access(self, user: User) -> None:
        role_names = {role.name for role in user.roles}
        if RoleName.MENTOR in role_names or RoleName.ADMIN in role_names:
            return
        entitlements = await AuthService(self.session, self.settings).get_entitlements(user.id)
        if "mentor_access" in {item.key for item in entitlements.features}:
            return
        raise AppError("forbidden", "Mentor access required", status_code=403)

    async def _ensure_link(self, mentor_id: UUID, student_id: UUID) -> MentorLink:
        link = await self.session.scalar(
            select(MentorLink).where(
                MentorLink.mentor_user_id == mentor_id,
                MentorLink.student_user_id == student_id,
                MentorLink.status == "active",
            )
        )
        if link is None:
            raise AppError("forbidden", "Student is not linked to this mentor", status_code=403)
        return link

    @staticmethod
    def _link_view(link: MentorLink) -> MentorLinkView:
        return MentorLinkView(
            id=link.id,
            mentor_user_id=link.mentor_user_id,
            student_user_id=link.student_user_id,
            status=link.status,
            created_at=link.created_at,
        )

    @staticmethod
    def _assignment_view(assignment: MentorAssignment) -> AssignmentView:
        return AssignmentView(
            id=assignment.id,
            mentor_user_id=assignment.mentor_user_id,
            student_user_id=assignment.student_user_id,
            topic_id=assignment.topic_id,
            title=assignment.title,
            note=assignment.note,
            due_at=assignment.due_at,
            status=assignment.status,
            created_at=assignment.created_at,
        )
