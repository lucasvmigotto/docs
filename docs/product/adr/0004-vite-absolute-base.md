# 0004 — Absolute Vite base plus Router basename per app

* Status: proposed
* Date: 2026-09-29

## Context and drivers

`rusteams`/`devenv` use default `base: '/'`; `tasky` uses `'./'`.
Under `/<app>/` absolute-root asset URLs 404. User depends on OG
meta + portfolio links, which need absolute canonical URLs.

## Considered options

* Absolute `base: '/<app>/'` + Router `basename: '/<app>'` + absolute
  OG (`https://docs.lucasvmigotto.me/<app>/og-image.png`).
* Relative `base: './'` everywhere, keep HashRouter unprefixed.

## Decision outcome

Absolute base. Couples build to deploy path (accepted: path is stable
contract owned by this architecture). Relative-base rejected: fixes
assets but leaves OG/canonical/sitemap guessing the prefix at runtime.

## Consequences

Good: correct preloads, favicons, OG/Twitter cards, sitemaps per app.
Bad: local `vite preview` serves at `/` — needs `--base` override or
env switch for prod parity; build must know its `<app>` name.
Bad (accepted): renaming a prefix requires rebuild.

## Confirmation

`dist/index.html` contains no `%VITE_*%` placeholders and
`og:image` is `https://docs.lucasvmigotto.me/<app>/og-image.png`;
`GET /<app>/` loads JS/CSS with 200s.
