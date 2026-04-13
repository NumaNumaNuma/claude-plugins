# Smoke: lint failure recovery

Verifies that Claude's 3-attempt fix loop for failing cleanup checks works.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-lint
cd /tmp/toy-lint
```

Modify `package.json` so `npm run lint` uses a script that will fail on a specific string appearing in the source:

```bash
node -e "
const fs = require('fs');
const p = JSON.parse(fs.readFileSync('package.json', 'utf8'));
p.scripts.lint = \"node -e \\\"const s=require('fs').readFileSync('src/index.mjs','utf8'); if (s.includes('BADTOKEN')) { console.error('lint failure: BADTOKEN found'); process.exit(1) } else { console.log('lint ok') }\\\"\";
fs.writeFileSync('package.json', JSON.stringify(p, null, 2));
"
git add package.json && git commit -m "rig lint to fail on BADTOKEN"
```

## Steps

- [ ] Run: `/pair-with-codex:start "add a function and include a comment with BADTOKEN that should be removed"` (hopefully Codex writes the comment)
- [ ] Proceed through spec, implement, continue to cleanup.
- [ ] In cleanup, `npm run lint` fails with "BADTOKEN found".
- [ ] Expected: Claude reads the error, removes BADTOKEN from the source, reruns lint. Up to 3 attempts.
- [ ] Expected: within 3 attempts, lint passes and cleanup completes.
- [ ] If lint still fails after 3 attempts, Claude writes state `failed` and stops (both outcomes are valid for this test — verify behavior matches one of them).

## Teardown

```bash
rm -rf /tmp/toy-lint
```
