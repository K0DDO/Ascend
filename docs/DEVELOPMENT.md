# Ascend Development Guide

## Repo layout

Monorepo:

- `backend/` — FastAPI
- `mobile/` — Flutter
- `docs/` — architecture source of truth
- `SYSTEM_PROMPT.md` — context recovery for AI/agents

## Prerequisites

- Python 3.12+
- Poetry or uv (decide in Phase 2; prefer **uv**)
- PostgreSQL 16+
- Flutter stable
- Docker optional for Postgres/Redis

## Backend (Phase 2+)

```bash
cd backend
uv sync
uv run alembic upgrade head
uv run uvicorn app.main:app --reload
```

Tests:

```bash
uv run pytest
```

## Mobile (Phase 3+)

```bash
cd mobile
flutter pub get
flutter run
flutter test
```

## Documentation workflow

1. Change architecture → update relevant `docs/*.md`
2. Update `docs/PROJECT_CONTEXT.md`
3. Update `SYSTEM_PROMPT.md` phase table
4. Commit

## Coding standards

### Backend
- Typed Python
- One domain module owns its models/services
- No god `services.py`
- Tests for auth, entitlements, SRS, sync

### Flutter
- Feature-first folders
- No Dio in widgets
- All colors/spacing via AscendTheme
- Prefer small widgets; avoid rebuild storms in card session

## Git

- `main` is primary branch
- Commit after meaningful steps
- Conventional, why-focused messages

## Environment

Never commit `.env` with secrets. Provide `.env.example` only.
