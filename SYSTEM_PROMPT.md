# ASCEND — SYSTEM PROMPT (Context Recovery)

> **Назначение:** читать этот файл ПЕРВЫМ, когда контекст чата обнулился.
> Обновлять после каждого значимого этапа работы.
> Последнее обновление: 2026-08-12 — Phases 11–15 (AI / Mentor / Admin / Sync / Prod)

---

## Что такое Ascend

**Ascend** — mobile-first часть образовательной платформы менторства по программированию.

Философия: `LEARN → REMEMBER → UNDERSTAND → PROVE → GET HIRED`

Это **не клон Anki**. Берём только spaced repetition + карточки.
Пользователь видит только `[Повторить]` / `[Знаю]`. Алгоритм сам считает интервалы.

Практический код — на сайте. Мобилка: теория, повторение, подготовка к собесам.

---

## Репозиторий

- Path: `c:\Users\dima4ka\Documents\Visual Studio 2022\Ascend`
- Remote: `https://github.com/K0DDO/Ascend.git`
- Branch: `main`
- Monorepo: `backend/` (Python/FastAPI) + `mobile/` (Flutter) + `docs/`

Reference design (visual language only, не копировать классы):
`c:\Users\dima4ka\Documents\Visual Studio 2022\Subbery`
Токены: `Subbery/SUBBERY_DESIGN_TOKENS.md`, `Subbery/SUBBERY_DESIGN_SYSTEM.md`

Исходные ответы владельца продукта: `Идея продукта.md`

---

## Tech stack (LOCKED)

### Mobile (Flutter)
- Flutter stable + Dart
- **Riverpod** (AsyncNotifier) — state
- **GoRouter** — navigation
- **Dio** — HTTP
- **Drift + SQLCipher** — encrypted offline DB
- **flutter_secure_storage** — keys/tokens (Keystore/Keychain)
- **freezed + json_serializable** — models
- Design via `AscendTheme` extension (never raw `Color(0xFF...)`)

### Backend (Python)
- **FastAPI** modular monolith
- **PostgreSQL** + **SQLAlchemy 2.x** + **Alembic**
- **Pydantic v2**
- **Redis** — later (rate limit, jobs, token denylist)
- **Arq** — later (LLM AI jobs); Phase 11 MVP = grounded scoring without Arq
- JWT access + refresh tokens
- Entitlements/permissions (НЕ hardcode `if plan == ...`)

### Infra principle
Один modular monolith + Flutter client. Без микросервисов на старте.

---

## Ключевые архитектурные решения

1. **Backend = source of truth.** Flutter = UI + offline + local SRS execution + event collection + sync.
2. **Event-sourced learning history** — append-only learning events; SRS canonical state пересчитывается на сервере.
3. **Entitlements model** — plans → feature flags/entitlements; клиент никогда не доверяет своим правам.
4. **Content versioning** — Card/Source имеют versions; `REVIEW_REQUIRED` / `DRAFT` никогда не показываются ученику.
5. **Encrypted offline content** — только entitlement-доступный контент; при revoke — wipe local content, stats остаются на сервере.
6. **SRS isolated domain** — `SRSAlgorithm` interface; формулы не в UI.
7. **AI Interview** — отдельный домен, требует entitlement + internet; grounded only on knowledge base.
8. **Web later** — та же API; бизнес-логика не живёт только в Flutter.

---

## Документация (читать по порядку)

1. `docs/PROJECT_CONTEXT.md` — текущий статус
2. `docs/ARCHITECTURE.md` — общая архитектура
3. `docs/DATABASE.md` — схема БД
4. `docs/API.md` — API contracts
5. `docs/SYNC.md` — offline/sync
6. `docs/SRS.md` — SRS algorithm interface
7. `docs/DESIGN_SYSTEM.md` — Ascend design tokens
8. `docs/SECURITY.md`
9. `docs/DEVELOPMENT.md`
10. `docs/IMPLEMENTATION_PLAN.md` — фазы

---

## Структура репозитория

```
Ascend/
  SYSTEM_PROMPT.md          ← этот файл
  README.md
  Идея продукта.md
  docs/
  backend/app/{core,auth,users,entitlements,courses,topics,knowledge,
               cards,learning,srs,progress,gamification,ai,mentor,
               admin,analytics,sync}/
  mobile/lib/{core,domain,data,features,shared}/
```

---

## Hotbar (mobile)

Home | Learn | Knowledge | Progress | Profile  
AI Interview — контекстно, не отдельная вкладка.

---

## Phase status

| Phase | Name | Status |
|-------|------|--------|
| 1 | Architecture | ✅ DONE |
| 2 | Backend foundation | ✅ DONE |
| 3 | Flutter foundation | ✅ DONE |
| 4 | Authentication | ✅ DONE |
| 5 | Course/content system | ✅ DONE |
| 6 | Offline storage | ✅ DONE |
| 7 | Cards UX | ✅ DONE |
| 8 | SRS | ✅ DONE |
| 9 | Progress | ✅ DONE |
| 10 | Gamification | ✅ DONE |
| 11 | AI Interview | ✅ DONE (MVP grounded: rubric + mistakes + entitlement UX) |
| 12 | Mentor | ✅ DONE (links / progress / assignments + student UI) |
| 13 | Admin | ✅ DONE (review queue / grants / analytics APIs) |
| 14 | Sync hardening | ✅ DONE (idempotent events + mobile outbox flush) |
| 15 | Production hardening | ✅ DONE (rate limit + security headers + docs) |

**Next (post Phase 15):** LLM examiner (optional Arq), richer admin/mentor mobile UI, multi-device sync torture tests in CI.

**First polished UI after foundation:** Home (glass + hotbar) → Learning card flip flow.

---

## Правила работы агента

1. НЕ начинать код без чтения этого файла + PROJECT_CONTEXT.
2. Каждый значимый шаг — git commit.
3. Не hardcode plan names; использовать entitlements.
4. Не показывать ученику DRAFT / REVIEW_REQUIRED cards.
5. Не логировать secrets / tokens / private content.
6. Обновлять PROJECT_CONTEXT.md и этот SYSTEM_PROMPT.md после этапов.
7. Коммитить после действий (по просьбе владельца).
8. Не overengineer: modular monolith, не микросервисы.

---

## Известные gaps / TBD

- Subbery reference изучен; Ascend Design System создан отдельно (не копировать имена классов Subbery).
- OAuth providers: email/password first; Google/Apple/Telegram linking — Phase 4+.
- Career / salary board / leagues — архитектурно заложены, UI позже.
- Telegram bot — out of mobile MVP; analytics hooks в backend.
- AI Interview: MVP is deterministic grounded scoring; full LLM examiner + Arq jobs still TBD.
- Admin mobile moderation UI is minimal/placeholder; APIs are primary.
- Certificate pinning decision deferred; rate limit is in-process (Redis later).
- Pre-existing: `test_ready_without_database` can fail against real DB in local env.

---

## Как продолжить после обнуления контекста

```
1. Прочитай SYSTEM_PROMPT.md
2. Прочитай docs/PROJECT_CONTEXT.md
3. Прочитай docs/IMPLEMENTATION_PLAN.md — текущая фаза / next gaps
4. git status / git log -5
5. Продолжай с next gaps (LLM examiner, admin mobile UI, sync CI torture)
```
