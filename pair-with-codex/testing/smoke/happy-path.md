# Smoke: happy path

Verifies the full `/pair-with-codex:start` flow on a toy repo with a small task.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-happy
cd /tmp/toy-happy
```

## Steps

- [ ] In Claude Code (with `/tmp/toy-happy` as cwd), run: `/pair-with-codex:start "add a farewell() function that returns 'goodbye, <name>'"`
- [ ] Claude prints the resolved flag summary. Confirm: `y`.
- [ ] Claude runs brainstorming and asks clarifying questions. Answer them briefly.
- [ ] Claude writes the spec. Approve at the spec gate.
- [ ] Claude invokes Codex, shows the job id, polls until done.
- [ ] Continue to cleanup at the gate.
- [ ] Claude runs simplify + `npm run lint` + `npm test`. All pass.
- [ ] Continue to review loop at the gate.
- [ ] Codex review runs. If clean, loop breaks immediately. If not, Claude addresses findings, asks to run another round.
- [ ] Loop ends. Done phase prints the summary.

## Expected result

- `git log --oneline` shows (at minimum): `initial toy repo`, `spec: ...`, `implement: ...`, `cleanup: ...`, and possibly one or more `review N: ...` commits.
- `src/index.mjs` now exports a `farewell` function.
- `npm run lint && npm test` passes.
- `~/.claude/pair-with-codex/sessions/` no longer contains an active session file for this repo.
- `~/.claude/pair-with-codex/sessions/archive/` contains a `last-run-summary.md` for the run.

## Teardown

```bash
rm -rf /tmp/toy-happy
```
