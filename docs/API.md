# Ascend API (`/api/v1`)

REST + JSON. Versioned prefix. OpenAPI generated from FastAPI.

## Conventions

| Topic | Rule |
|-------|------|
| Auth | `Authorization: Bearer <access_token>` |
| IDs | UUID strings |
| Time | ISO-8601 UTC |
| Errors | `{ "error": { "code", "message", "details?", "request_id" } }` |
| Pagination | `cursor` + `limit` (default 50, max 200) |
| Idempotency | `Idempotency-Key` on event ingest & purchases |
| Entitlements | Always server-evaluated |

---

## Auth

| Method | Path | Notes |
|--------|------|-------|
| POST | `/auth/register` | email/password |
| POST | `/auth/login` | → access + refresh |
| POST | `/auth/refresh` | rotating refresh |
| POST | `/auth/logout` | revoke refresh |
| GET | `/auth/me` | profile + roles |
| POST | `/auth/oauth/{provider}` | later |
| POST | `/auth/link/telegram` | later |

---

## Entitlements

| Method | Path |
|--------|------|
| GET | `/me/entitlements` |
| GET | `/me/features/{feature_key}` |

Response example:

```json
{
  "features": [
    { "key": "course_access", "constraints": {}, "ends_at": null },
    { "key": "ai_interview", "constraints": { "monthly_quota": 10 }, "ends_at": null }
  ]
}
```

---

## Content

| Method | Path | Notes |
|--------|------|-------|
| GET | `/content/manifest` | entitled courses/topics + revisions/hashes |
| GET | `/content/packages` | `?since_revision=` batched encrypted blobs metadata |
| GET | `/content/packages/{id}` | download package |
| GET | `/courses` | entitled + locked stubs |
| GET | `/courses/{id}` | |
| GET | `/topics/{id}` | includes prerequisites state |
| GET | `/topics/{id}/cards` | published only |
| GET | `/documents/{id}` | latest published source for entitled users |

Admin content write APIs live under `/admin/...`.

---

## Learning & sync

| Method | Path | Notes |
|--------|------|-------|
| POST | `/sync/events` | batch append learning events |
| GET | `/sync/state` | canonical srs_states + progress snapshot |
| POST | `/sessions` | start session |
| PATCH | `/sessions/{id}` | end session |
| GET | `/learn/optimal` | server-suggested queue (online); offline uses local scheduler |

### POST `/sync/events`

```json
{
  "device_id": "...",
  "events": [
    {
      "id": "client-uuid",
      "session_id": "...",
      "card_id": "...",
      "card_version_id": "...",
      "result": "know",
      "started_at": "...",
      "question_revealed_at": "...",
      "flipped_at": "...",
      "completed_at": "...",
      "source_opened_at": null,
      "source_closed_at": null,
      "timings": { "question_ms": 12000, "answer_ms": 3000 },
      "app_version": "0.1.0"
    }
  ]
}
```

Response: accepted ids, rejected (with reason), updated `srs_states` delta, progress delta.

Duplicate `event.id` → idempotent success.

---

## Progress & gamification

| Method | Path |
|--------|------|
| GET | `/me/home` | home aggregate DTO |
| GET | `/me/progress` | |
| GET | `/me/topics/{id}/mastery` | |
| GET | `/me/activity` | calendar |
| GET | `/me/streak` | |
| GET | `/me/achievements` | |

---

## AI Interview (entitlement `ai_interview`)

| Method | Path | Notes |
|--------|------|-------|
| POST | `/ai/interviews/start` | body: `topic_id`, `question_count` |
| GET | `/ai/interviews/{id}` | session + turns + optional summary |
| POST | `/ai/interviews/{id}/answer` | body: `answer`; returns rubric + score |
| GET | `/ai/interviews/{id}/mistakes` | mistakes for session |
| GET | `/ai/interviews/mistakes/deck` | user mistakes deck |

MVP scoring is grounded (card text overlap + rubric dimensions). Offline start → clear client blocked/error state (online-only).

---

## Mentor

Requires `mentor`/`admin` role **or** entitlement `mentor_access` (except student “mine” list).

| Method | Path |
|--------|------|
| POST | `/mentor/links` | body: `student_user_id` |
| GET | `/mentor/students` | |
| GET | `/mentor/students/{id}/progress` | |
| POST | `/mentor/assignments` | |
| GET | `/mentor/assignments` | mentor list |
| GET | `/mentor/assignments/mine` | student list |
| POST | `/mentor/assignments/{id}/comments` | append mentor note |

---

## Admin

Prefix `/admin` — role `admin` required.

| Method | Path |
|--------|------|
| GET | `/admin/content/review-queue` | `REVIEW_REQUIRED` cards |
| PATCH | `/admin/content/cards/{id}/status` | `draft`/`review_required`/`published`/`archived` |
| POST | `/admin/entitlements/grants` | grant feature to user |
| GET | `/admin/analytics/overview` | users / sessions / review / sync counts |

---

## Sync

| Method | Path |
|--------|------|
| POST | `/sync/events` | batch ingest; idempotent by `(user_id, idempotency_key)` |
| GET | `/sync/diagnostics` | pending estimate + recent failures |

---

## Analytics (ingest)

| Method | Path |
|--------|------|
| POST | `/analytics/events` | client funnel crumbs (non-PII) |

---

## Home DTO (contract sketch)

```json
{
  "greeting_name": "Андрей",
  "streak_days": 14,
  "daily_goal": { "target": 24, "done": 0 },
  "cta": { "type": "start_learning", "label": "Start learning" },
  "weak_areas": [
    { "topic_id": "...", "title": "AsyncIO", "mastery": 61 }
  ],
  "course_progress": [
    { "title": "Python", "mastery": 94 }
  ],
  "next_goal": { "title": "Close AsyncIO" },
  "readiness": { "label": "Mock Interview", "percent": 82 }
}
```

---

## Error codes (selected)

| code | HTTP |
|------|------|
| `unauthenticated` | 401 |
| `forbidden` | 403 |
| `entitlement_required` | 403 |
| `not_found` | 404 |
| `conflict` | 409 |
| `validation_error` | 422 |
| `review_required_content` | 409 |
| `rate_limited` | 429 |
| `ai_unavailable_offline` | 503 |
