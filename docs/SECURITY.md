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
- In-process rate limit middleware (`Settings.rate_limit_per_minute`, default 120; Redis later)
- CORS allowlist
- Security headers (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`)
- Request IDs (`X-Request-ID` + structured log field)
- Idempotency keys on `/sync/events` ingest
- Admin routes gated by `require_admin`; mentor by role or `mentor_access` entitlement

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

TLS only in production. Certificate pinning — deferred (evaluate before store release).
