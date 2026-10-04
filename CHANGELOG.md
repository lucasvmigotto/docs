# Changelog

Releases are plain SemVer git tags (`0.1.0`, no `v` prefix), decided from
the Conventional Commits since the last tag by `scripts/release.py`. The
site's version lives in `site/package.json` and is bumped by the same
script.

## 0.1.0 — 2026-10-04

### Added

- **Central docs hub landing** at `docs.lucasvmigotto.me`, listing every
  project with a description, tech tags, a live docs link and a source link.
- **One shared R2 bucket**: the landing owns `/` and each project publishes
  under its own `/<project>/` prefix; the landing deploys root-only and
  never runs a root `--delete`.

### Changed

- Projects derive their build base and deploy prefix from the repository
  name, and deploy workflows carry a guard that fails any R2 target that is
  not prefix-scoped.
