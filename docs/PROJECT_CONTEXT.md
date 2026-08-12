# Ascend — Project Context

> Living document. Update after every phase.
> Last updated: 2026-08-12 — Phase 10 Gamification

## Current status

**Phase 10 — Gamification: COMPLETE**

Next: Phase 11 AI Interview.

## Product one-liner

Personal system that takes a mentorship student from learning theory to interview-ready employment — mobile-first cards + knowledge + (entitled) AI interviews, synced with the web platform.

## Tech stack

See `ARCHITECTURE.md` / `SYSTEM_PROMPT.md`.

## Folder structure

```
Ascend/
  SYSTEM_PROMPT.md
  README.md
  docs/*.md
  backend/app/{core,auth,content,entitlements,...}/
  mobile/lib/{core,data,features,shared}/
```

## Implemented features

- [x] Architecture documentation set
- [x] Backend runnable app (`/api/v1/health`, `/api/v1/ready`)
- [x] Alembic: identity + auth + content curriculum
- [x] Flutter shell with AscendTheme and glass hotbar
- [x] Auth (register/login/refresh/logout, JWT, entitlements, devices)
- [x] Mobile auth UI (welcome/login/register, demo mode, secure token storage)
- [x] Content API (courses, topics, cards, sources, manifest stub)
- [x] Demo seed: `demo-python` (demo_access) + `python-pro` (course_access, locked)
- [x] Flutter Learn tab: course list with topics preview
- [x] Offline: Drift + SQLCipher local DB, content sync, entitlement wipe on logout
- [x] Learn tab: offline badge + pull-to-refresh
- [x] Cards UX: TopicScreen, CardPlayer flip-анимация, Повторить/Знаю, итоговый экран
- [x] Backend: learning_events table, POST /learning/reviews, GET /learning/topics/{id}/progress
- [x] SRS: ascend_srs_v1 algorithm, card_memory_states, due-queue endpoint, Flutter SRS-ordered queue
- [x] Progress: `/progress/overview`, weak areas, 14-day activity, readiness + live Progress tab UI
- [x] Gamification: `/gamification/overview`, streak, XP, daily goal, achievements + live Progress UI section
- [ ] AI Interview
- [ ] Mentor
- [ ] Admin

## Current TODO

1. Phase 11: AI Interview (entitlement gate, grounded examiner, scoring)
2. Then Mentor

## Dev quick start

```bash
cd backend
docker compose up -d
alembic upgrade head
python scripts/seed_content.py
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

```bash
cd mobile
flutter pub get
adb reverse tcp:8001 tcp:8001
flutter run --release --dart-define=API_BASE_URL=http://127.0.0.1:8001
```

Postgres runs on host port **55432** (avoids local PostgreSQL conflict).

## Content endpoints (Phase 5)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/v1/courses` | Published courses; locked flag per entitlement |
| GET | `/api/v1/courses/{id}` | Sections + topics when unlocked |
| GET | `/api/v1/topics/{id}` | Topic detail + prerequisite ids |
| GET | `/api/v1/topics/{id}/cards` | Published card previews |
| GET | `/api/v1/documents/{id}` | Published source blocks |
| GET | `/api/v1/content/manifest` | Revision manifest stub |
| GET | `/api/v1/content/packages` | Empty stub (offline packages later) |

## Known issues

- Docker Desktop required for Postgres (`docker compose up -d`).
- Physical device dev uses USB + `adb reverse` (Windows Firewall blocks LAN port by default).
- Release APK requires `INTERNET` permission in main manifest (fixed).

## Reference materials

- `Идея продукта.md` — owner Q&A
- Subbery design tokens — visual language reference
