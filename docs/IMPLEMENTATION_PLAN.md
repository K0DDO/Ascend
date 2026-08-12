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

## Phase 3 — Flutter foundation ✅

- [x] `flutter create` into `mobile/`
- [x] Riverpod + GoRouter shell
- [x] AscendTheme (colors, spacing, radius, glass, typography, animations)
- [x] Floating glass hotbar + placeholder tabs
- [x] Light/Dark/System toggle in Profile
- [x] Home preview with glass cards

**Exit criteria:** App runs with branded shell.

## Phase 4 — Authentication ✅

- [x] Register/login/refresh
- [x] Secure token storage
- [x] Auth gate + demo entry
- [x] Device registration

## Phase 5 — Course / content system ✅

- [x] Schema: courses, topics, dependencies, sources, cards, versions
- [x] Demo seed script (`scripts/seed_content.py`)
- [x] Manifest + package download stubs
- [x] Published-only visibility + entitlement locks
- [x] Flutter Learn tab with course list

## Phase 6 — Offline storage ✅

- [x] Drift schema: courses, topics, cards, entitlements, sync meta, outbox
- [x] SQLCipher encrypted DB (Android/iOS); in-memory DB for tests
- [x] ContentSyncService: network sync → local store; cache fallback
- [x] Entitlement-scoped purge (locked course content wiped locally)
- [x] Wipe all local content on logout / demo mode
- [x] Learn tab offline badge + pull-to-refresh
- [x] Unit tests: `LocalContentStore`

## Phase 7 — Cards UX ✅

- [x] Backend: `learning_events` table + migration 004
- [x] Backend: `POST /learning/reviews`, `GET /learning/topics/{id}/progress`
- [x] Flutter: TopicScreen — список карточек + прогресс-бар дня
- [x] Flutter: CardPlayerScreen — flip-анимация (3D), Повторить / Знаю
- [x] Flutter: итоговый экран сессии со статистикой
- [x] Flutter: навигация Learn → Topic → Card Player (GoRouter nested routes)
- [x] Review записывается на backend fire-and-forget (offline-resilient)

## Phase 8 — SRS ✅

- [x] `ascend_srs_v1` server algorithm
- [x] `card_memory_states` persistence + migration
- [x] Due queue endpoint (`/learning/topics/{id}/queue`)
- [x] Tests (algorithm properties and bounds)

## Phase 9 — Progress ✅

- [x] Backend DTO: `/progress/overview`
- [x] Weak areas (topic mastery from review history)
- [x] Activity strip (14-day review counts)
- [x] Readiness indicator (know-rate + due-load blend)
- [x] Flutter Progress tab connected to live backend metrics

## Phase 10 — Gamification ✅

- [x] Backend DTO: `/gamification/overview`
- [x] Streak calculation from learning events
- [x] XP totals (`know`/`repeat` weighted), including `xp_today`
- [x] Daily goal progress
- [x] Achievements list with unlocked/progress
- [x] Flutter Progress tab: streak/xp/daily goal/achievements

## Phase 11 — AI Interview

- [x] Entitlement gate (`ai_interview`)
- [x] Grounded examiner (card-based Q&A)
- [x] Structured rubric + confidence bands
- [x] Mistakes deck per session
- [x] Mobile: progress, rubric, summary, blocked state

## Phase 12 — Mentor

- [x] Student linking (`/mentor/links`)
- [x] Progress snapshot for linked students
- [x] Assignments + mentor comments
- [x] Mobile: student assignments screen (`/mentor`)

## Phase 13 — Admin

- [x] Review queue + card status workflow
- [x] Entitlement grants API
- [x] Analytics overview
- [x] Admin role enforcement

## Phase 14 — Sync hardening

- [x] Idempotent sync events table + batch ingest
- [x] Mobile outbox enqueue on failed review
- [x] Outbox flush on content sync
- [x] Sync diagnostics endpoint

## Phase 15 — Production hardening

- [x] Rate limit middleware (per-IP/path)
- [x] Security headers middleware
- [x] Request ID structured logging
- [x] Docs updated

---

## Near-term milestone (after Phase 3–4)

**M1 — “Beautiful Home + offline-capable card flip against stub/local data”**

Demonstrates Ascend identity before full backend content pipeline.
