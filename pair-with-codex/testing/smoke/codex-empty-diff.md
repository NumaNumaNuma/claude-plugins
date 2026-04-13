# Smoke: Codex empty diff

Verifies that Claude does NOT silently proceed when Codex produces an empty diff.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-empty
cd /tmp/toy-empty
```

## Steps

- [ ] Run: `/pair-with-codex:start "do nothing, leave the code exactly as it is"`
- [ ] Proceed through spec. The spec may genuinely conclude there is nothing to do.
- [ ] Expected: in the implement phase, after Codex runs, Claude detects the empty diff.
- [ ] Expected (hybrid): Claude prints the Codex output and asks "Codex made no changes. Continue to cleanup / retry with clarification / abort?". Choose `abort`.
- [ ] Expected (auto, if this test is also run in auto mode): Claude writes `failed` state with `failed: codex produced no changes` and stops.

## Teardown

```bash
rm -rf /tmp/toy-empty
```
