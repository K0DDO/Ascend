# Ascend Sync & Offline Architecture

## Goals

1. Card learning works fully offline.
2. Multi-device history never drops events.
3. Server remains source of truth after merge.
4. Entitled content encrypted at rest on device.
5. No `POST /sync` of entire database.

---

## Data classes on device

| Store | Contents | Encryption |
|-------|----------|------------|
| Secure storage | refresh token, DB key, wrapped content keys | Keystore/Keychain |
| SQLCipher DB | cards, sources, local SRS, event outbox, progress cache | SQLCipher |
| Temp files | download packages | deleted after import |

---

## Sync protocol (event-based)

```
Client                         Server
  |  POST /sync/events (batch)    |
  |------------------------------>|
  |  accepted + SRS/progress delta|
  |<------------------------------|
  |  GET /sync/state?since=cursor |
  |------------------------------>|
  |  canonical snapshot/delta     |
  |<------------------------------|
  |  GET /content/manifest        |
  |------------------------------>|
```

### Push: learning events

- Client writes events to **outbox** immediately (local txn with SRS optimistic update).
- When online, flush outbox in order (per device), batches of ≤100.
- Server appends (idempotent by `event.id`), recomputes SRS for touched cards, returns deltas.
- Client marks outbox rows `acked`, applies server SRS (server wins).

### Pull: canonical state

- Cursor-based: `state_version` / `updated_at` watermark.
- Includes: `srs_states`, `topic_progress`, streak, daily goal, entitlements etag, content revision.

### Pull: content

- Manifest compares `content_revision` + package hashes.
- Download only entitled changed packages.
- UI: “New content available” / “N cards updated”.

---

## Conflict rules

| Conflict | Resolution |
|----------|------------|
| Same card reviewed on two devices offline | **Keep both events**; recompute SRS from merged timeline by `completed_at` (+ tie-break `event.id`) |
| Divergent optimistic SRS | Server recomputed state overwrites client |
| Entitlement lost mid-queue | Stop serving locked cards; wipe packages; keep aggregated stats on server |
| Card deleted/unpublished while local due | Drop from local queue; tombstone |

**Forbidden:** last-write-wins on learning history.

---

## Offline SRS

- Client embeds `ascend_srs_v1` (same version string as server).
- Optimistic schedule for UX continuity.
- After sync, replace with server state.
- If algorithm_version mismatch → force full state pull; disable optimistic until updated app (or server ships compatible rules).

---

## AI interview sessions

- Require network at start.
- Persist server-side interview state continuously.
- If connection drops: client keeps local draft answers; resume via `GET /ai/interviews/{id}`; do not fabricate scoring offline.

---

## Encryption scheme (high level)

1. On first login, client generates `db_key` → store in secure storage.
2. Server issues per-user `content_key` wrapped with device public key / or derived via login KEK exchange (implementation detail in SECURITY.md).
3. Content packages encrypted with `content_key`.
4. On logout / entitlement revoke: delete SQLCipher DB content tables / packages; optionally destroy content_key.

Plain JSON course dumps on disk are **not allowed**.

---

## Diagnostics

Log (non-sensitive): outbox depth, last sync cursor, conflict counts, content revision, algorithm_version.
Surface in Profile → Diagnostics for support.
