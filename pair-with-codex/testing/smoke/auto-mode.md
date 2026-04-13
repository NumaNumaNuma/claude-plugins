# Smoke: auto mode

Verifies that `--auto` skips all pause gates on a trivial task.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-auto
cd /tmp/toy-auto
```

## Steps

- [ ] Run: `/pair-with-codex:start --auto "add a wave() function"`
- [ ] Expected: Claude prints the resolved flag summary (no y/n prompt), then runs through the full flow without stopping for any gate.
- [ ] Codex runs, cleanup runs, review loop runs, done.
- [ ] Expected: the run finishes without any user interaction after the initial command.

## Expected result

- Full commit history as in happy-path.
- `last-run-summary.md` exists in the archive dir with the task description, timing, and commit list.

## Teardown

```bash
rm -rf /tmp/toy-auto
```
