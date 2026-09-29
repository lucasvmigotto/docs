# 0001 — Single R2 bucket with per-app prefixes

* Status: proposed
* Date: 2026-09-29

## Context and drivers

Each app deploys a static site; user has 10 free rewrite rules and wants
unlimited documented projects under `docs.lucasvmigotto.me/<app>`.
Cost must be $0, operated by one person. Multiple buckets cannot share one
hostname without a Worker in front.

## Considered options

* Single bucket, `<app>/` prefixes + landing at `/`.
* Bucket per app, unified behind Worker/routes.
* Keep per-app `<app>.domain` + rule each (status quo).

## Decision outcome

Single bucket with prefixes. One R2 Custom Domain, root owned solely by
`docs/` repo, each app writes only its prefix with prefix-scoped
`--delete`. Status quo rejected: caps at 10 apps. Per-app buckets
rejected: same storage cost, extra routing layer, N custom domains.

## Consequences

Good: 1 domain, 2 rules for N apps; per-prefix updates; $0.
Bad: blast radius of a root `--delete` is total — needs CI guard;
shared token across repos until collector evolution.
Bad (accepted): bucket-level settings (lifecycle, CORS) are shared.

## Confirmation

`GET /`, `/tasky`, `/rusteams/`, `/devenv/` all 200 from R2; rule count
stays 2 after adding 4th app.
