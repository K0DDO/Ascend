# Ascend — Project Context

> Living document. Update after every phase.
> Last updated: 2026-08-12

## Current status

**Phase 2 — Backend foundation: COMPLETE**

FastAPI app boots with health/ready endpoints, async SQLAlchemy, Alembic baseline migration, pytest.

**Phase 3 — Flutter foundation: IN PROGRESS**

## Product one-liner

Personal system that takes a mentorship student from learning theory to interview-ready employment — mobile-first cards + knowledge + (entitled) AI interviews, synced with the web platform.

## Tech stack

See `ARCHITECTURE.md` / `SYSTEM_PROMPT.md`.

## Folder structure

```
Ascend/
  SYSTEM_PROMPT.md
  README.md
  Идея продукта.md
  docs/*.md
  backend/app/<modules>/
  mobile/lib/{core,domain,data,features,shared}/
```

## Implemented features

- [x] Architecture documentation set
- [x] Repository scaffold
- [x] Backend runnable app (`/api/v1/health`, `/api/v1/ready`)
- [x] Alembic baseline: users, roles, user_roles
- [ ] Flutter runnable app
- [ ] Auth
- [ ] Content
- [ ] Offline
- [ ] Cards UI
- [ ] SRS
- [ ] Progress
- [ ] Gamification
- [ ] AI Interview
- [ ] Mentor
- [ ] Admin

## Current TODO

1. Phase 3: Flutter foundation (`flutter create`, AscendTheme, shell/hotbar skeleton)
2. Then Auth → Content → Offline → Cards → SRS

## Backend quick start

```bash
cd backend
python -m venv .venv && .venv\Scripts\activate
pip install -e ".[dev]"
docker compose up -d
alembic upgrade head
uvicorn app.main:app --reload
```

## Known issues

- None in code (no runtime yet).
- Subbery is external reference only; do not import Subbery packages.

## Open product nuances (resolved for architecture)

| Topic | Decision |
|-------|----------|
| Locked topics visibility | Show locked with upsell sheet |
| Access expiry | Wipe local entitled content; keep server aggregates |
| Prerequisites | Hard gate for all learning paths, not only Optimal |
| Card multi-topic | Primary topic + optional secondary tags later; v1 = one primary topic |
| AI required for 100% topic | When user has `ai_interview` entitlement; otherwise mastery thresholds without AI |
| Deleted card | Soft-remove from learning; preserve course-level aggregates |

## Architectural decisions

See ADR table in `ARCHITECTURE.md`.

## Reference materials

- `Идея продукта.md` — owner Q&A
- Subbery design tokens — visual language reference
- Owner master prompt — product + engineering requirements
