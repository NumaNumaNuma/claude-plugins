# Smoke: dirty tree refusal

Verifies that `:start` refuses when the working tree is dirty, and that `--allow-dirty` overrides.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-dirty
cd /tmp/toy-dirty
echo "untracked" > untracked.txt
```

## Steps

- [ ] Run: `/pair-with-codex:start "add a docstring to greet"`
- [ ] Expected: Claude refuses with a clear message mentioning the dirty tree and the `--allow-dirty` escape hatch.
- [ ] Run: `/pair-with-codex:start --allow-dirty "add a docstring to greet"`
- [ ] Expected: Claude proceeds past preflight, prints the resolved flag summary including `allow_dirty: true`.
- [ ] Abort with `/pair-with-codex:abort` (we do not need to complete this run).
- [ ] Expected: state is cleared; `untracked.txt` is untouched.

## Teardown

```bash
rm -rf /tmp/toy-dirty
```
