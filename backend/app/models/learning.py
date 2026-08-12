import enum
import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.user import _enum_values


class ReviewResult(str, enum.Enum):
    REPEAT = "repeat"
    KNOW = "know"


class LearningEvent(Base):
    __tablename__ = "learning_events"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    card_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("cards.id", ondelete="CASCADE"), nullable=False, index=True
    )
    card_version_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("card_versions.id", ondelete="CASCADE"), nullable=False
    )
    result: Mapped[ReviewResult] = mapped_column(
        Enum(ReviewResult, name="review_result", native_enum=False, values_callable=_enum_values),
        nullable=False,
    )
    question_ms: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    answer_ms: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    source_opened: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    completed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
