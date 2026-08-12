"""Demo curriculum seed used by scripts and tests."""

import uuid
from datetime import UTC, datetime
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.content import (
    Card,
    CardSourceReference,
    CardStatus,
    CardVersion,
    Course,
    CourseSection,
    PublishStatus,
    SourceBlock,
    SourceBlockType,
    SourceDocument,
    SourceVersion,
    Topic,
    TopicDependency,
)

DEMO_COURSE_ID = uuid.UUID("10000000-0000-4000-8000-000000000001")
PRO_COURSE_ID = uuid.UUID("10000000-0000-4000-8000-000000000002")
DEMO_SECTION_ID = uuid.UUID("11000000-0000-4000-8000-000000000001")
PRO_SECTION_ID = uuid.UUID("11000000-0000-4000-8000-000000000002")
TOPIC_BASICS_ID = uuid.UUID("12000000-0000-4000-8000-000000000001")
TOPIC_FUNCTIONS_ID = uuid.UUID("12000000-0000-4000-8000-000000000002")
TOPIC_ASYNC_ID = uuid.UUID("12000000-0000-4000-8000-000000000003")
DOC_BASICS_ID = uuid.UUID("13000000-0000-4000-8000-000000000001")
DOC_VERSION_ID = uuid.UUID("13100000-0000-4000-8000-000000000001")
CARD_ONE_ID = uuid.UUID("14000000-0000-4000-8000-000000000001")
CARD_TWO_ID = uuid.UUID("14000000-0000-4000-8000-000000000002")
CARD_VERSION_ONE_ID = uuid.UUID("14100000-0000-4000-8000-000000000001")
CARD_VERSION_TWO_ID = uuid.UUID("14100000-0000-4000-8000-000000000002")
BLOCK_H1_ID = uuid.UUID("13200000-0000-4000-8000-000000000001")
BLOCK_P1_ID = uuid.UUID("13200000-0000-4000-8000-000000000002")
NOW = datetime.now(UTC)


async def ensure_demo_content(session: AsyncSession) -> None:
    if await session.scalar(select(Course.id).where(Course.slug == "demo-python")):
        return

    session.add_all(
        [
            Course(
                id=DEMO_COURSE_ID,
                slug="demo-python",
                title="Python — демо",
                description="Бесплатный фрагмент курса для знакомства с Ascend.",
                status=PublishStatus.PUBLISHED,
                content_revision=1,
                access_feature_key="demo_access",
            ),
            Course(
                id=PRO_COURSE_ID,
                slug="python-pro",
                title="Python Pro",
                description="Полный курс: от основ до async и FastAPI.",
                status=PublishStatus.PUBLISHED,
                content_revision=1,
                access_feature_key="course_access",
            ),
        ]
    )
    session.add_all(
        [
            CourseSection(
                id=DEMO_SECTION_ID,
                course_id=DEMO_COURSE_ID,
                title="Основы",
                position=1,
            ),
            CourseSection(
                id=PRO_SECTION_ID,
                course_id=PRO_COURSE_ID,
                title="Продвинутый уровень",
                position=1,
            ),
        ]
    )
    session.add_all(
        [
            Topic(
                id=TOPIC_BASICS_ID,
                section_id=DEMO_SECTION_ID,
                slug="python-basics",
                title="Основы Python",
                description="Переменные, типы и функции.",
                position=1,
                estimated_minutes=20,
                status=PublishStatus.PUBLISHED,
            ),
            Topic(
                id=TOPIC_FUNCTIONS_ID,
                section_id=DEMO_SECTION_ID,
                slug="functions",
                title="Функции",
                description="Определение и вызов функций.",
                position=2,
                estimated_minutes=15,
                status=PublishStatus.PUBLISHED,
            ),
            Topic(
                id=TOPIC_ASYNC_ID,
                section_id=PRO_SECTION_ID,
                slug="asyncio",
                title="AsyncIO",
                description="Асинхронность в Python.",
                position=1,
                estimated_minutes=30,
                status=PublishStatus.PUBLISHED,
            ),
        ]
    )
    session.add(
        TopicDependency(
            topic_id=TOPIC_FUNCTIONS_ID,
            prerequisite_topic_id=TOPIC_BASICS_ID,
        )
    )
    session.add(
        SourceDocument(
            id=DOC_BASICS_ID,
            topic_id=TOPIC_BASICS_ID,
            title="Введение в Python",
            status=PublishStatus.PUBLISHED,
        )
    )
    session.add(
        SourceVersion(
            id=DOC_VERSION_ID,
            document_id=DOC_BASICS_ID,
            version=1,
            checksum="demo-checksum-v1",
            published_at=NOW,
        )
    )
    session.add_all(
        [
            SourceBlock(
                id=BLOCK_H1_ID,
                source_version_id=DOC_VERSION_ID,
                block_key="h1",
                type=SourceBlockType.HEADING,
                position=1,
                payload={"text": "Что такое Python?", "level": 1},
            ),
            SourceBlock(
                id=BLOCK_P1_ID,
                source_version_id=DOC_VERSION_ID,
                block_key="p1",
                type=SourceBlockType.PARAGRAPH,
                position=2,
                payload={"text": "Python — язык общего назначения с простым синтаксисом."},
            ),
        ]
    )
    session.add_all(
        [
            Card(
                id=CARD_ONE_ID,
                topic_id=TOPIC_BASICS_ID,
                status=CardStatus.PUBLISHED,
                difficulty=Decimal("0.350"),
            ),
            Card(
                id=CARD_TWO_ID,
                topic_id=TOPIC_BASICS_ID,
                status=CardStatus.PUBLISHED,
                difficulty=Decimal("0.450"),
            ),
        ]
    )
    session.add_all(
        [
            CardVersion(
                id=CARD_VERSION_ONE_ID,
                card_id=CARD_ONE_ID,
                version=1,
                front={"text": "Как объявить переменную в Python?"},
                back={"text": "name = value — без указания типа."},
                metadata_={},
                published_at=NOW,
            ),
            CardVersion(
                id=CARD_VERSION_TWO_ID,
                card_id=CARD_TWO_ID,
                version=1,
                front={"text": "Какой тип у литерала 3.14?"},
                back={"text": "float"},
                metadata_={},
                published_at=NOW,
            ),
        ]
    )
    session.add_all(
        [
            CardSourceReference(
                id=uuid.uuid4(),
                card_version_id=CARD_VERSION_ONE_ID,
                document_id=DOC_BASICS_ID,
                source_version_id=DOC_VERSION_ID,
                block_id=BLOCK_P1_ID,
                position=0,
            ),
            CardSourceReference(
                id=uuid.uuid4(),
                card_version_id=CARD_VERSION_TWO_ID,
                document_id=DOC_BASICS_ID,
                source_version_id=DOC_VERSION_ID,
                block_id=BLOCK_P1_ID,
                position=0,
            ),
        ]
    )
    await session.commit()
