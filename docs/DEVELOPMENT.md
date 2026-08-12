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
# venv already used in this repo:
.venv\Scripts\alembic upgrade head
.venv\Scripts\python -m pytest tests/ -q
.venv\Scripts\uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

Dev DB often on host port **55432** (see `backend/.env` / docker compose). API commonly on **8001**.

Tests:

```bash
.venv\Scripts\python -m pytest tests/ -q
```

Known: `test_ready_without_database` may fail when a real DB is reachable from the test settings override path.

## Mobile (Phase 3+)

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=API_BASE_URL=http://127.0.0.1:8001
adb reverse tcp:8001 tcp:8001
adb install -r build/app/outputs/flutter-apk/app-release.apk
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
