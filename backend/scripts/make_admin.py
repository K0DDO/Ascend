"""Promote a user to admin role by email (dev helper)."""

from __future__ import annotations

import argparse
import asyncio

from sqlalchemy import select

from app.core.config import get_settings
from app.core.database import get_engine, get_session_factory
from app.models.user import Role, RoleName, User, UserRole


async def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--email", required=True)
    args = parser.parse_args()

    settings = get_settings()
    engine = get_engine(settings)
    factory = get_session_factory(settings)
    async with factory() as session:
        user = await session.scalar(select(User).where(User.email == args.email))
        if user is None:
            raise SystemExit(f"User not found: {args.email}")
        role = await session.scalar(select(Role).where(Role.name == RoleName.ADMIN))
        if role is None:
            raise SystemExit("Admin role missing")
        existing = await session.scalar(
            select(UserRole).where(UserRole.user_id == user.id, UserRole.role_id == role.id)
        )
        if existing:
            print("already admin")
        else:
            session.add(UserRole(user_id=user.id, role_id=role.id))
            await session.commit()
            print(f"granted admin to {args.email}")
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())
