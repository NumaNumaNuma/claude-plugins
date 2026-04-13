# Smoke: resume after kill

Verifies that a session can be resumed from the cleanup phase after a terminal kill.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-resume
cd /tmp/toy-resume
```

## Steps

- [ ] Run: `/pair-with-codex:start "add a wave() function that returns 'wave at <name>'"`
- [ ] Proceed through spec approval and implement. Codex finishes, continue to cleanup.
- [ ] During cleanup, close the terminal / kill the Claude Code process.
- [ ] Verify the state file exists: `ls ~/.claude/pair-with-codex/sessions/`
- [ ] Open a new Claude Code session, cwd = `/tmp/toy-resume`.
- [ ] Run: `/pair-with-codex:resume`
- [ ] Expected: Claude prints the last known phase and recent commits, asks whether to resume, resumes on `y`.
- [ ] The flow continues from cleanup and finishes.

## Expected result

- Final `git log --oneline` shows the full expected sequence of commits.
- No duplicate commits (the resumed session should not redo what was already committed).

## Teardown

```bash
rm -rf /tmp/toy-resume
```
