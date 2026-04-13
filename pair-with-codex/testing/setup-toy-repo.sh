#!/usr/bin/env bash
# setup-toy-repo.sh — create a minimal reproducible fixture for pair-with-codex smoke tests.
# Usage: ./setup-toy-repo.sh [target-dir]
# Default target: /tmp/pair-with-codex-toy

set -euo pipefail

TARGET="${1:-/tmp/pair-with-codex-toy}"

if [[ -d "$TARGET" ]]; then
  echo "Target $TARGET already exists. Remove it first or choose another path." >&2
  exit 1
fi

mkdir -p "$TARGET"
cd "$TARGET"

git init --quiet --initial-branch=main

cat > package.json <<'JSON'
{
  "name": "pair-with-codex-toy",
  "version": "0.0.1",
  "type": "module",
  "scripts": {
    "lint": "node -e \"import('./src/index.mjs').then(() => console.log('lint ok'))\"",
    "test": "node --test test/*.test.mjs"
  }
}
JSON

mkdir -p src test

cat > src/index.mjs <<'JS'
export function greet(name) {
  return `hello, ${name}`;
}
JS

cat > test/greet.test.mjs <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";
import { greet } from "../src/index.mjs";

test("greet returns a greeting", () => {
  assert.equal(greet("world"), "hello, world");
});
JS

cat > README.md <<'MD'
# pair-with-codex toy repo

A minimal fixture for pair-with-codex smoke tests. Do not use for real work.
MD

git add -A
git commit --quiet -m "initial toy repo"

echo "Toy repo created at $TARGET"
echo "Verify: cd $TARGET && npm run lint && npm test"
