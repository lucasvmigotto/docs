# 0003 — Apps push directly to their R2 prefix

* Status: proposed
* Date: 2026-09-29

## Context and drivers

Docs source stays in app repos; a change must update only
`docs.lucasvmigotto.me/<app>`. Single-credential ideal vs simplicity;
team of one; deploys ~5/day.

## Considered options

* App CI builds and `aws s3 sync dist/ s3://$BUCKET/<app>/` directly.
* App CI uploads artifact + `repository_dispatch` to `docs/`; central
  workflow holds sole R2 key and deploys.
* Central rebuild (submodules/sparse checkout, build all in `docs/`).

## Decision outcome

Direct prefix push (MVP). No artifact expiry, no cross-repo PAT, no
central queue; true per-app updates. Collector rejected for now: still
needs a PAT in every app repo, adds fetch/queue failure modes.
Central rebuild rejected: must replicate bun/cargo toolchains per app.

## Consequences

Good: simplest, fastest, scales to N apps with no central changes.
Bad: same R2 token duplicated in N repos — rotation is manual until
evolution trigger (N > ~15 or rotation pain).
Bad (accepted): no single audit point; each repo owns its deploy logs.

## Confirmation

Push to `tasky/main` updates only `/tasky/` timestamp; other prefixes
untouched; no root `--delete` in any workflow.
