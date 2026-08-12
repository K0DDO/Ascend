# Ascend Implementation Plan

## Phase 1 — Architecture ✅

- [x] Analyze repo + product Q&A + Subbery tokens
- [x] Architecture docs
- [x] Monorepo scaffold
- [x] SYSTEM_PROMPT.md

## Phase 2 — Backend foundation ✅

- [x] FastAPI app skeleton, settings, logging, error handlers
- [x] SQLAlchemy async engine/session
- [x] Alembic baseline (users, roles, user_roles + seed roles)
- [x] `GET /api/v1/health`, `GET /api/v1/ready`
- [x] pytest wiring (3 tests)
- [x] `.env.example`, docker-compose, README

**Exit criteria:** API boots, health green, migrations apply on empty Postgres.
Run: `docker compose up -d && alembic upgrade head` when Docker is available.

## Phase 3 — Flutter foundation

- `flutter create` into `mobile/`
- Riverpod + GoRouter shell
- AscendTheme (colors, spacing, radius, glass, animations)
- Floating glass hotbar + placeholder tabs
- Light/Dark/System

**Exit criteria:** App runs with branded shell.

## Phase 4 — Authentication

- Register/login/refresh
- Secure token storage
- Auth gate + demo entry
- Device registration

## Phase 5 — Course / content system

- Schema: courses, topics, dependencies, sources, cards, versions
- Admin seed path (API or script)
- Manifest + package download stubs
- Published-only visibility

## Phase 6 — Offline storage

- SQLCipher/Drift
- Encrypted import
- Entitlement-scoped wipe
- Outbox table

## Phase 7 — Cards UX

- Session player
- Physical flip
- Repeat / Know
- Source reader with block highlight
- **First polished flow with Home**

## Phase 8 — SRS

- `ascend_srs_v1` server + client
- Optimal queue + prerequisites
- Tests

## Phase 9 — Progress

- Home DTO live
- Mastery, weak areas, activity calendar
- Readiness indicators

## Phase 10 — Gamification

- Streak, XP ledger, daily goal, achievements
- Adult presentation

## Phase 11 — AI Interview

- Entitlement gate
- Grounded examiner
- Scoring + mistakes deck
- Admin overrides

## Phase 12 — Mentor

- Student linking, progress views, assignments, comments

## Phase 13 — Admin

- Content workflow, REVIEW_REQUIRED, plans/entitlements, analytics

## Phase 14 — Sync hardening

- Multi-device torture tests
- Conflict suites
- Diagnostics UI

## Phase 15 — Production hardening

- Rate limits, observability, pinning decision, store readiness

---

## Near-term milestone (after Phase 3–4)

**M1 — “Beautiful Home + offline-capable card flip against stub/local data”**

Demonstrates Ascend identity before full backend content pipeline.
