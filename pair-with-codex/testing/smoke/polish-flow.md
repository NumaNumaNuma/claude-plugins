# Smoke: polish flow

Verifies that `:polish` runs cleanup + review loop on existing working-tree changes without planning or Codex implementation.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-polish
cd /tmp/toy-polish
cat >> src/index.mjs <<'JS'

export function wave(name) {
return `wave at ${name}`
}
JS
```

Note: the added function has intentionally inconsistent indentation and a missing semicolon — `simplify` and the lint check should notice.

## Steps

- [ ] Run: `/pair-with-codex:polish "add wave function"`
- [ ] Expected: Claude skips planning, starts at cleanup.
- [ ] Cleanup runs simplify, which normalizes the formatting. `npm run lint` and `npm test` pass.
- [ ] Review loop runs. Addresses any findings.
- [ ] Done.

## Expected result

- `git log --oneline` shows: `initial toy repo`, `cleanup: add wave function`, possibly `review N: ...`.
- No `spec:` or `implement:` commits (polish skips these).
- The wave function still works: `node -e "import('./src/index.mjs').then(m => console.log(m.wave('world')))"` prints `wave at world`.

## Teardown

```bash
rm -rf /tmp/toy-polish
```
