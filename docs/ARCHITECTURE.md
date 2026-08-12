# Ascend Architecture

## 1. Product framing

Ascend is the **mobile learning client** of a mentorship education platform.

```
LEARN → REMEMBER → UNDERSTAND → PROVE → GET HIRED
```

| Surface | Responsibility |
|---------|----------------|
| Mobile (Flutter) | Theory, SRS cards, progress, offline learning, contextual AI interview |
| Web (future) | Same learning core + code practice + admin/mentor richer UX |
| Backend (Python) | Source of truth for identity, content, entitlements, learning, AI, analytics |

Mobile must **not** own unique business rules that cannot be reused on web.

---

## 2. System context

```
┌─────────────┐     HTTPS/JSON      ┌──────────────────────┐
│ Flutter iOS │◄───────────────────►│  FastAPI Monolith    │
│ Flutter And │   event sync        │  /api/v1/...         │
└──────┬──────┘                     └──────────┬───────────┘
       │ encrypted Drift/SQLCipher             │
       ▼                                       ▼
┌─────────────┐                     ┌──────────────────────┐
│ Local store │                     │ PostgreSQL           │
│ Secure keys │                     │ (+ Redis later)      │
└─────────────┘                     └──────────────────────┘
```

---

## 3. Locked tech stack

### Flutter
| Concern | Choice | Why |
|---------|--------|-----|
| State | Riverpod 2 (AsyncNotifier) | Testable, compile-safe DI, scales to offline |
| Routing | GoRouter | Deep links, auth redirects, shell routes |
| HTTP | Dio | Interceptors for auth/refresh/idempotency |
| Local DB | Drift + SQLCipher | Typed queries + encrypted at rest |
| Secrets | flutter_secure_storage | Keystore / Keychain |
| Models | freezed + json_serializable | Immutable DTOs, unions for sync states |
| Theme | AscendTheme ThemeExtension | Centralized design tokens |

### Backend
| Concern | Choice | Why |
|---------|--------|-----|
| API | FastAPI | Async, OpenAPI, Pydantic v2 |
| ORM | SQLAlchemy 2.x | Typed mappings, mature ecosystem |
| Migrations | Alembic | Production schema evolution |
| DB | PostgreSQL | Relational integrity for graph + events |
| Jobs | Arq (later) | Redis-backed AI jobs when needed |
| Cache/limits | Redis (later) | Rate limits, refresh denylist |

**Not in v1:** microservices, Kafka, GraphQL, desktop app.

---

## 4. Layering

### Backend module layout

```
backend/app/
  core/           # config, db, security, logging, errors
  auth/
  users/
  entitlements/   # plans, features, grants
  courses/
  topics/         # prerequisites graph
  knowledge/      # source documents/blocks/versions
  cards/          # cards, versions, publish workflow
  learning/       # sessions, events
  srs/            # algorithm, card state, scheduler
  progress/       # mastery, readiness
  gamification/   # xp, streak, achievements
  ai/             # interviews (entitlement-gated)
  mentor/
  admin/
  analytics/      # acquisition, funnel
  sync/           # pull/push protocol
```

Each module: `models.py`, `schemas.py`, `repository.py`, `service.py`, `router.py`, tests.

### Flutter layout

```
mobile/lib/
  core/           # theme, network, storage, routing, widgets
  domain/         # pure entities + SRS interfaces (no Flutter)
  data/           # repositories, DTOs, local/remote sources
  features/
    auth/
    home/
    learning/
    cards/
    knowledge/
    progress/
    profile/
    ai_interview/
    shell/        # hotbar + scaffold
  shared/
```

Dependency rule:

```
UI (features) → application controllers → domain → repositories → data sources
```

Widgets never call Dio directly.

---

## 5. Domain boundaries

### Content (admin-owned)
Course → Section → Topic → (SourceDocument, Cards)  
TopicDependency (DAG)  
SourceBlock references on CardVersion

### Access
User → Role → EntitlementGrant ← Plan/Feature  
Server enforces every request.

### Learning
LearningSession → LearningEvent* (append-only)  
CardState / SRSState (derived, server-canonical; client may compute optimistic)

### Proof
AIInterview* (online only)  
WeakConcept → MistakeDeck

### Growth (later modules, schema reserved)
CareerProfile, Referral, ConversionEvent, MentorAssignment

---

## 6. Entitlements (critical)

**Never:**

```python
if plan == "mentorship":
    ...
```

**Always:**

```python
if await access.has(user_id, Feature.AI_INTERVIEW):
    ...
```

Canonical features (extensible):

| Feature key | Meaning |
|-------------|---------|
| `demo_access` | Marketing demo slice |
| `course_access` | Full course tree |
| `topic_access` | Specific topic IDs |
| `ai_interview` | AI examiner |
| `mentor_access` | Mentor messaging/assignments |
| `mock_interview` | Human mock interview booking |
| `career_section` | Career board |
| `advanced_statistics` | Deep analytics |

Plans (DEMO, COURSE, MENTORSHIP, SINGLE_TOPIC, …) are **admin-configurable bundles of features**, not code branches.

---

## 7. Content delivery

1. Client authenticates → server returns effective entitlements.
2. Client requests content manifest (versions, hashes) for entitled scope.
3. Client downloads encrypted packages (batched).
4. Packages decrypted with device key from secure storage + server-delivered content key (wrapped).
5. On entitlement revoke/expiry: wipe entitled local content blobs; keep anonymized local queue empty; server retains aggregates.

Course assets are **never** shipped in the app bundle.

---

## 8. Auth flow (summary)

1. Register/login (email/password; OAuth later).
2. Receive `access_token` (short) + `refresh_token` (rotating).
3. Store refresh in secure storage.
4. Device registration (`device_id`) for multi-device sync.
5. Purchase on web attaches entitlements to same user → next `/me/entitlements` refresh unlocks content.

Telegram account linking is identity binding, not a separate product account.

---

## 9. Offline-first cards

| Capability | Offline |
|------------|---------|
| Review cards | ✅ |
| Read source | ✅ |
| Local SRS schedule | ✅ optimistic |
| Learning events | ✅ queued |
| Streak/daily goal | ✅ local estimate |
| AI interview | ❌ requires network |
| Content updates | ❌ until online |

See `SYNC.md`, `SRS.md`.

---

## 10. Cross-platform reuse strategy

To enable future web without rewrite:

- All mastery, SRS merge, entitlements, content publish rules live on **backend**.
- Flutter `domain/` SRS can mirror server for offline, but **server wins** after sync.
- API contracts versioned (`/api/v1`); web consumes the same.
- Shared OpenAPI → generate Dart/TS clients later if needed.

---

## 11. Screen map (mobile)

| Screen | Purpose |
|--------|---------|
| Marketing / Demo gate | Unauth / no purchase |
| Auth | Login, register, link |
| Shell + Hotbar | Home, Learn, Knowledge, Progress, Profile |
| Home | What now / weak areas / goal proximity |
| Learn hub | Topics + Optimal Learning |
| Card session | Flip → Repeat/Know |
| Source reader | Full notes + highlight block |
| Knowledge | Course graph / notes browser |
| Progress | Mastery, calendar, readiness |
| Profile | Account, theme, devices |
| AI Interview | Contextual entry; online |
| Work on mistakes | Temporary deck from AI |

---

## 12. Architectural decisions log

| ID | Decision | Alternatives | Why chosen |
|----|----------|--------------|------------|
| AD-1 | Modular monolith | Microservices | Solo/small team, one deploy, clear modules |
| AD-2 | Drift+SQLCipher | Hive, Isar, plain SQLite | Encryption + relational queries for cards/events |
| AD-3 | Riverpod | BLoC, Provider | Less boilerplate, better testing for offline |
| AD-4 | Event append + server SRS recompute | Last-write-wins state | Multi-device correctness |
| AD-5 | Entitlements not plan enums | Plan string switches | New tariffs without app release |
| AD-6 | Card versioning + REVIEW_REQUIRED | In-place edit | Never teach unverified content |
| AD-7 | Custom SRS behind interface | Raw FSRS UI intervals | Product UX: two buttons only |
| AD-8 | Matte glass DS from Subbery tokens | Copy Subbery widgets | Same premium feel, Ascend naming |

---

## 13. Non-goals (near term)

- User-generated public decks
- Anki `.apkg` import for students (admin tooling maybe later)
- Desktop app
- Social feed / chat rooms
- Leagues until ~100+ students
