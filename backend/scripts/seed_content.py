"""Seed demo curriculum content. Safe to run multiple times."""

import asyncio

from app.content.seed import ensure_demo_content
from app.core.config import get_settings
from app.core.database import get_engine, get_session_factory


async def seed() -> None:
    session_factory = get_session_factory()
    async with session_factory() as session:
        await ensure_demo_content(session)
        print("Demo content seeded.")


def main() -> None:
    settings = get_settings()
    get_engine(settings)
    asyncio.run(seed())


if __name__ == "__main__":
    main()
