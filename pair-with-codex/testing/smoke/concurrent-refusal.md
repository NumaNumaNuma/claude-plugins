# Smoke: concurrent invocation refusal

Verifies that a second `:start` in the same repo is refused while one session is active, but runs on a different repo work fine.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-concur-a
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-concur-b
```

## Steps

- [ ] In Claude Code session A (cwd = `/tmp/toy-concur-a`), run: `/pair-with-codex:start "add a wave() function"`
- [ ] Proceed through to the implement phase (Codex running).
- [ ] In the same Claude Code session, **also** in `/tmp/toy-concur-a`, run `/pair-with-codex:start "something else"`.
- [ ] Expected: refusal with a message listing the active session (task, phase, started_at) and pointing at `:status`, `:resume`, `:abort`.
- [ ] In a second Claude Code window (cwd = `/tmp/toy-concur-b`), run: `/pair-with-codex:start "add a goodbye() function"`.
- [ ] Expected: starts normally — different repo, different state file.
- [ ] Abort both sessions with `:abort`.

## Teardown

```bash
rm -rf /tmp/toy-concur-a /tmp/toy-concur-b
```
