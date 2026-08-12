"""Create a published card via admin API (dev helper).

Usage:
  .venv\\Scripts\\python scripts\\create_card.py --email admin@example.com --password ... --topic-id ... --front "Q" --back "A"
"""

from __future__ import annotations

import argparse
import asyncio
import sys
from uuid import UUID

import httpx


async def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default="http://127.0.0.1:8001")
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--topic-id", required=True)
    parser.add_argument("--front", required=True)
    parser.add_argument("--back", required=True)
    parser.add_argument("--document-id")
    parser.add_argument("--source-version-id")
    parser.add_argument("--block-id")
    args = parser.parse_args()

    async with httpx.AsyncClient(base_url=args.base_url, timeout=30) as client:
        login = await client.post(
            "/api/v1/auth/login",
            json={
                "email": args.email,
                "password": args.password,
                "device_id": "create-card-script",
                "platform": "android",
                "app_version": "0.1.0",
            },
        )
        if login.status_code != 200:
            print(login.text, file=sys.stderr)
            return 1
        token = login.json()["tokens"]["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        sources = []
        if args.document_id and args.source_version_id:
            sources.append(
                {
                    "document_id": args.document_id,
                    "source_version_id": args.source_version_id,
                    "block_id": args.block_id,
                    "position": 0,
                }
            )

        create = await client.post(
            f"/api/v1/admin/content/topics/{args.topic_id}/cards",
            headers=headers,
            json={
                "front_text": args.front,
                "back_text": args.back,
                "publish": True,
                "sources": sources,
            },
        )
        print(create.status_code, create.text)
        return 0 if create.status_code == 200 else 1


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))
