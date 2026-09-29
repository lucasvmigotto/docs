# 0002 — Directory index via Transform Rewrite, not Worker

* Status: proposed
* Date: 2026-09-29

## Context and drivers

R2 Custom Domains serve exact keys, no directory-index fallback:
`GET /tasky` → `NoSuchKey`. All sites use HashRouter, so only the initial
document needs fallback — no SPA catch-all. Budget $0, rule budget 2/10.

## Considered options

* Two generic Transform Rewrite rules (`concat(path, "/index.html")` /
  `concat(path, "index.html")`) with operator-only filters (free-plan safe).
* Cloudflare Worker router with fallback logic.
* One dynamic rule with `regex_replace` (needs regex entitlement, double-slash edge).

## Decision outcome

Two Rewrite rules. Rule 1 filter:
`http.host == "docs.lucasvmigotto.me" and not http.request.uri.path ends with "/" and not http.request.uri.path contains "."`.
Rule 2 filter:
`http.host == "docs.lucasvmigotto.me" and http.request.uri.path ends with "/"`.
Single-expression variant rejected: `concat()` may appear once, so
trailing-slash vs naked-prefix can't share one rewrite without `//`.

## Consequences

Good: $0, zero code to operate, saves 8 rules, unlimited apps.
Bad: no logic beyond index fallback (no auth, no pretty 404 per app).
Bad (accepted): two rules instead of one.

## Confirmation

Cloudflare Trace shows `/tasky` → `/tasky/index.html`, `/` →
`/index.html`, `/tasky/assets/x-abc.js` untouched.
