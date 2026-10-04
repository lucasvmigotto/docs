#!/usr/bin/env bash
# Tests scripts/release.py in throwaway repositories driven by release.json:
# which commits release and at which level, the single-manifest version bump,
# CHANGELOG promotion or generation, ignored commits, --dry-run, --notes and
# the no-tag initial release. Run it after changing scripts/release.py.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE="$REPO_DIR/scripts/release.py"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.test
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.test

failures=0
check() { # check <description> <command...>
  local what="$1"
  shift
  if "$@"; then
    printf '      ok    %s\n' "$what"
  else
    printf '      FAIL  %s\n' "$what"
    failures=$((failures + 1))
  fi
}

# A base repository tagged 0.1.0: one site manifest listed in release.json.
base="$SANDBOX/base"
mkdir -p "$base/site"
printf '{\n  "name": "docs-hub",\n  "version": "0.1.0"\n}\n' >"$base/site/package.json"
echo "# site" >"$base/site/README.md"
printf '{\n  "manifests": [{ "file": "site/package.json" }]\n}\n' >"$base/release.json"
printf '# Changelog\n\nIntro.\n\n## 0.1.0 — 2026-01-01\n\nFirst.\n' >"$base/CHANGELOG.md"
git -C "$base" init -q -b main
git -C "$base" add -A
git -C "$base" commit -q -m "chore: initial"
git -C "$base" tag -a 0.1.0 -m 0.1.0

repo="" out=""
fresh() { repo="$SANDBOX/r$RANDOM$RANDOM"; git clone -q "$base" "$repo"; }
edit() { # edit <file> <commit subject> [<body>]
  echo "change $RANDOM" >>"$repo/$1"
  git -C "$repo" add -A
  if (($# > 2)); then git -C "$repo" commit -q -m "$2" -m "$3"; else git -C "$repo" commit -q -m "$2"; fi
}
run() { # run <args...>: sets out and rc
  set +e
  out="$(cd "$repo" && python3 "$RELEASE" --date 2026-02-02 "$@" 2>/dev/null)"
  rc=$?
  set -e
}
site_version() { python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$repo/site/package.json"; }
# shellcheck disable=SC2329 # called through check()
clean() { [[ -z "$(git -C "$repo" status --porcelain)" ]]; }

echo "      -- no release"
fresh
edit README.md "docs: explain"
edit CHANGELOG.md "chore: tidy"
run
check "docs and chore only → exit 3" test "$rc" -eq 3
check "nothing written" clean
edit README.md "chore(release): 9.9.9"
run
check "chore(release) ignored" test "$rc" -eq 3
git -C "$repo" switch -q -c topic
edit README.md "docs: topic notes"
git -C "$repo" switch -q main
git -C "$repo" merge -q --no-ff -m "feat: merge subject that must not count" topic
run
check "merge subject ignored" test "$rc" -eq 3

echo "      -- levels"
fresh
edit site/README.md "fix: handle empty input"
run
check "fix → patch 0.1.1" test "$rc" -eq 0 -a "$out" == "0.1.1"
check "  manifest bumped" test "$(site_version)" == "0.1.1"
check "  generated Fixed section" grep -q '^- handle empty input$' "$repo/CHANGELOG.md"
check "  new section above 0.1.0" bash -c 'grep -n "^## " "$1" | head -1 | grep -q "0.1.1 — 2026-02-02"' _ "$repo/CHANGELOG.md"
run --notes
check "  --notes prints the new section" bash -c '[[ "$1" == *"### Fixed"* && "$1" != *"First."* ]]' _ "$out"

fresh
edit site/README.md "feat: add export"
run
check "feat → minor 0.2.0" test "$rc" -eq 0 -a "$out" == "0.2.0"
check "  Added section" grep -q '^### Added' "$repo/CHANGELOG.md"

fresh
edit site/README.md "refactor!: rename the entry point"
run
check "type! → major 1.0.0" test "$rc" -eq 0 -a "$out" == "1.0.0"
check "  Breaking section" grep -q '^### Breaking' "$repo/CHANGELOG.md"

fresh
edit README.md "fix: parse dates" "BREAKING CHANGE: dates are now ISO 8601 only"
run
check "BREAKING CHANGE footer → major 1.0.0" test "$rc" -eq 0 -a "$out" == "1.0.0"
check "  footer text in Breaking" grep -q '^- dates are now ISO 8601 only$' "$repo/CHANGELOG.md"

fresh
sed -i 's/"version": "0.1.0"/"version": "0.3.0"/' "$repo/site/package.json"
edit site/README.md "feat: bump by hand"
run
check "hand-bumped version left alone" test "$(site_version)" == "0.3.0"

echo "      -- changelog"
fresh
python3 - "$repo/CHANGELOG.md" <<'EOF'
import sys
p = sys.argv[1]
s = open(p).read().replace("## 0.1.0", "## Unreleased\n\nHand-written notes.\n\n## 0.1.0", 1)
open(p, "w").write(s)
EOF
git -C "$repo" commit -q -am "docs: notes for the next release"
edit site/README.md "fix: something"
run
check "## Unreleased renamed to the release" bash -c 'grep -q "^## 0.1.1 — 2026-02-02$" "$1" && ! grep -q "^## Unreleased" "$1"' _ "$repo/CHANGELOG.md"
check "  hand-written notes kept, nothing generated" bash -c 'grep -q "^Hand-written notes.$" "$1" && ! grep -q "^- something$" "$1"' _ "$repo/CHANGELOG.md"

echo "      -- dry run"
fresh
edit site/README.md "fix: x"
run --dry-run
check "prints the plan" bash -c '[[ "$1" == "release 0.1.1 (patch, since 0.1.0)"* && "$1" == *"manifest site/package.json: 0.1.0 -> 0.1.1 (patch)"* ]]' _ "$out"
check "writes nothing" clean

echo "      -- no tag yet"
repo="$SANDBOX/untagged"
mkdir -p "$repo/site"
printf '{\n  "name": "docs-hub",\n  "version": "0.1.0"\n}\n' >"$repo/site/package.json"
printf '{\n  "manifests": [{ "file": "site/package.json" }]\n}\n' >"$repo/release.json"
git -C "$repo" init -q -b main
git -C "$repo" add -A
git -C "$repo" commit -q -m "feat: first feature"
run
check "first release defaults to 0.1.0" test "$rc" -eq 0 -a "$out" == "0.1.0"
check "  CHANGELOG created" test -f "$repo/CHANGELOG.md"

echo "      -- errors"
run --initial 1.0
check "bad --initial → exit 2" test "$rc" -eq 2
repo="$SANDBOX/not-a-repo"
mkdir -p "$repo"
run
check "outside a repository → exit 1" test "$rc" -eq 1

exit $((failures > 0))
