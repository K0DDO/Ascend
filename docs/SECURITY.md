# Ascend Security

## Principles

1. Never trust client-provided role, plan, or entitlements.
2. Server authorizes every sensitive operation.
3. Educational content encrypted at rest on device.
4. No secrets in source, logs, or analytics payloads.
5. Audit admin mutations.

---

## Authentication

- Passwords: Argon2id (or bcrypt if ops constraint — prefer Argon2id).
- Access JWT: short-lived (e.g. 15m), signed RS256/ES256.
- Refresh: opaque, rotating, stored hashed server-side, bound to `device_id`.
- Secure storage on client for refresh + crypto keys.
- Multi-device allowed; each device has own refresh row.

---

## Authorization

Layers:

1. Authentication required?
2. Role check (`admin`, `mentor`, …)
3. Entitlement/feature check + constraints (topic scope, quota)
4. Resource ownership / mentor-student relation

Demo users get `demo_access` only.

---

## Content protection

- No full course in app assets.
- SQLCipher database; keys in Keystore/Keychain.
- On entitlement expiry/revoke: delete local content partitions.
- Aggregated learning stats remain on server.
- API returns only entitled published content.

---

## API hardening

- Pydantic validation everywhere
- Parameterized SQL (SQLAlchemy)
- Rate limits on auth + AI endpoints (Redis later)
- CORS allowlist
- Security headers
- Request IDs
- Idempotency keys on event ingest

---

## AI safety

- Grounding: only approved knowledge base
- Refuse when material missing
- Quota via entitlements
- Admin can invalidate bad questions
- Do not send unnecessary PII to model providers

---

## Logging / privacy

**Never log:** passwords, tokens, refresh values, raw card content dumps, full interview transcripts in insecure logs.

Admin audit log: actor, action, entity, before/after hashes, request_id.

---

## Transport

TLS only in production. Certificate pinning — evaluate at production hardening phase.
