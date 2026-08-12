# Ascend Database Design

PostgreSQL. Identifiers: **UUID v7** (time-ordered) preferred; UUID v4 acceptable at start.
All tables: `created_at`, `updated_at` (timestamptz). Soft delete via `deleted_at` where noted.

---

## ER overview (conceptual)

```
User ──┬── UserIdentity (email/oauth/telegram)
       ├── Device
       ├── EntitlementGrant ── Feature
       │         ▲
       │       PlanFeature ── Plan
       ├── LearningEvent ── CardVersion
       ├── CardState / SRSState
       ├── TopicProgress / CourseProgress
       ├── Streak / XP / Achievement
       ├── AIInterview*
       └── CareerProfile (later)

Course ── CourseSection ── Topic ── TopicDependency (DAG)
                              ├── SourceDocument ── SourceVersion ── SourceBlock
                              └── Card ── CardVersion ── CardSourceReference
```

---

## Identity & access

### users
| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| display_name | text | |
| email | citext unique null | |
| password_hash | text null | oauth-only users |
| status | enum | active, disabled |
| locale | text | default `ru` |
| acquisition_source_id | uuid FK null | |
| deleted_at | timestamptz null | soft |

### user_identities
Provider links: `email`, `google`, `apple`, `telegram`, …
Unique `(provider, provider_subject)`.

### devices
`user_id`, `device_id` (client-generated), `platform`, `app_version`, `last_seen_at`.

### roles
`admin`, `mentor`, `student` (extensible). Users may have multiple roles.

### features
Stable string keys: `course_access`, `ai_interview`, …

### plans
Admin-defined products: DEMO, COURSE, MENTORSHIP, SINGLE_TOPIC, custom.

### plan_features
M2M with optional JSON constraints (`topic_ids`, `ai_monthly_quota`, …).

### entitlement_grants
| Column | Notes |
|--------|-------|
| user_id | |
| feature_key | |
| source | purchase, admin, demo, referral |
| constraints | jsonb (topic scope, quotas) |
| starts_at / ends_at | nullable end = lifetime |
| revoked_at | |

**Rule:** authorization reads grants, never plan name.

---

## Curriculum graph

### courses
`slug`, `title`, `description`, `status` (draft/published), `content_revision` (monotonic int).

### course_sections
`course_id`, `title`, `position`.

### topics
`section_id`, `slug`, `title`, `position`, `estimated_minutes`, `status`.

### topic_dependencies
`topic_id`, `prerequisite_topic_id`  
Unique pair. **No cycles** — validated in service.  
Optional `proposed_by` (`admin`|`ai`), `confirmed_at` — AI proposals inactive until confirmed.

---

## Knowledge (source)

### source_documents
`topic_id`, `title`, `status`.

### source_versions
`document_id`, `version` int, `editor_id`, `checksum`, `published_at` null if draft.

### source_blocks
| Column | Notes |
|--------|-------|
| id | uuid |
| source_version_id | |
| block_key | stable id within version lineage when possible |
| type | heading, paragraph, list, code, quote, table, callout, divider, link |
| position | int |
| payload | jsonb (text, language, level, items, …) |

Cards reference `(document_id, block_id, source_version_id)`.

When source changes → new `source_versions` row; affected cards → `REVIEW_REQUIRED`.

---

## Cards

### cards
| Column | Notes |
|--------|-------|
| id | logical card identity |
| topic_id | primary topic |
| status | draft, review_required, published, archived |
| difficulty | numeric 0–1 seed |
| deleted_at | soft; removed from active learning |

### card_versions
`card_id`, `version`, `front` (jsonb rich text), `back` (jsonb), `metadata` jsonb, `created_by`, `published_at`.

Learner always sees **latest published** version. Learning events store `card_version_id`.

### card_source_references
`card_version_id`, `document_id`, `block_id`, `source_version_id`, optional `range`.

---

## Learning & SRS

### learning_sessions
`user_id`, `device_id`, `mode` (optimal, topic, mistakes, …), `started_at`, `ended_at`.

### learning_events  (append-only)
| Column | Notes |
|--------|-------|
| id | uuid (client may generate; idempotent) |
| user_id | |
| device_id | |
| session_id | |
| card_id | |
| card_version_id | |
| result | `repeat` \| `know` |
| started_at / question_revealed_at / flipped_at / completed_at | |
| source_opened_at / source_closed_at | nullable |
| timings | jsonb normalized metrics |
| app_version | |
| synced_at | server receive time |

**Indexes:** `(user_id, completed_at)`, `(card_id, user_id)`, unique `(id)` for idempotency.

**No cascade delete** from cards that destroys events — FK SET NULL or retain with card_id tombstone + `card_deleted` flag.

### srs_states
Canonical per `(user_id, card_id)`:

| Column | Notes |
|--------|-------|
| stability | |
| difficulty | |
| retrievability | cached/derived |
| due_at | |
| interval_days | |
| reps / lapses | |
| last_event_id | |
| algorithm_version | e.g. `ascend_srs_v1` |

Server recomputes from ordered events. Client optimistic copy allowed.

---

## Progress & gamification

### topic_progress
`user_id`, `topic_id`, `mastery` 0–100, `retention`, `status` (locked, available, in_progress, completed), `ai_score` null.

### course_progress
Aggregates + readiness toward mock interview / job-ready.

### streaks
`user_id`, `current`, `longest`, `last_qualified_date` (user TZ).

### daily_goals
`user_id`, `date`, `target_cards`, `completed_cards`, `xp_earned`.

### xp_ledger
Append-only XP grants with `reason` enum.

### achievements / user_achievements

---

## AI interview (MVP)

### ai_interview_sessions
`user_id`, `topic_id`, `status` (`in_progress`/`completed`), `current_index`, `score`, `rubric_json`.

### ai_interview_turns
`session_id`, `turn_index`, `card_id`, `question`, `reference_answer`, `user_answer`, `score`, `feedback`, `rubric_json`
(dimensions: clarity / correctness / completeness / terminology).

### ai_mistake_items
Per weak turn: `user_id`, `session_id`, `turn_id`, `card_id`, `topic_id`, `prompt`, `expected_hint`, `user_answer`, `score`.

LLM question bank / admin overrides — later.

---

## Mentor

### mentor_links
`mentor_user_id`, `student_user_id`, `status` (`active`), unique pair.

### mentor_assignments
`mentor_user_id`, `student_user_id`, optional `topic_id`, `title`, `note` (comments appended), `due_at`, `status`.

Mentors **cannot** mutate global content.

---

## Sync

### sync_events
`user_id`, `device_id`, `event_type`, `idempotency_key` (unique per user), `payload_json`, `status`.

---

## Analytics

### acquisition_sources
utm_* + internal channel ids.

### conversion_events
Funnel steps: visit, register, demo_open, purchase, learn_start, topic_complete, job_ready, employed.

Immutable where possible.

### career_profiles (later)
employment fields, salary visibility, contact opt-in.

---

## Indexing & constraints (highlights)

- Unique published card slug per topic if used
- Exclusion: no circular topic_dependencies (app-level + optional recursive CTE check)
- Partial index on `cards(status) WHERE deleted_at IS NULL AND status = 'published'`
- BRIN/BTREE on `learning_events(completed_at)` for analytics
- GIN on jsonb payloads only when query patterns demand

---

## Deletion policy

| Entity | Policy |
|--------|--------|
| Card | Soft delete; stop scheduling; keep events; recompute topic aggregates excluding card |
| Card version | Immutable; supersede by newer |
| User | Soft delete; anonymize PII after retention policy |
| Entitlement | Revoke; content wipe client-side |

**Never** `ON DELETE CASCADE` from `cards` → `learning_events`.
