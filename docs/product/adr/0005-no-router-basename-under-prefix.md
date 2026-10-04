# 0005 — No router basename under a path prefix

* Status: accepted
* Date: 2026-10-04

## Context and drivers

ADR 0004 prescribed an absolute Vite `base: '/<app>/'` **plus** a Router
`basename: '/<app>'` per app, to keep assets, OG and canonical URLs correct
under the hub prefix. Deploying the first projects into the shared bucket
exposed a bug: every page rendered as a bare background, no content.

All sites use `HashRouter`. A hash router matches routes against the URL
**hash**, never the pathname, so `basename: '/<app>'` makes it look for the
prefix *inside the hash* (`#/<app>/…`), match nothing, and render an empty
tree. Reproduced by rendering the production `App` under JSDOM:

```
<Router basename="/rusteams"> is not able to match the URL "/" because it
does not start with the basename, so the <Router> won't render anything.
```

## Considered options

* Keep `base` + router `basename` (ADR 0004) — the observed blank page.
* Keep Vite `base`; set **no** router `basename`.
* Drop `base` and use relative asset paths — rejected by 0004 (leaves
  canonical/OG/sitemap guessing the prefix at runtime).

## Decision outcome

Vite `base: '/<app>/'` stays: it makes assets, favicon and canonical/OG
URLs resolve under the prefix. The router sets **no** `basename`: the hash
route space (`#/`, `#/usage`, …) is identical at every prefix, so the path
prefix must not leak into the router. This supersedes the `basename` clause
of ADR 0004; its `base` clause stands.

## Consequences

Good: pages render; deep links (`#/…`) work at any prefix; OG and assets
stay absolute under the prefix.
Bad (accepted): the router is prefix-agnostic, so a future move to history
routing (`BrowserRouter`) would need a `basename` **and** an SPA fallback,
which the two-rewrite-rule setup (ADR 0002) deliberately does not provide.

## Confirmation

`GET /<app>/` renders the app (JSDOM: `#root` has children, not zero);
its JS/CSS return 200; a hash deep link such as `#/usage` resolves to its
page.
