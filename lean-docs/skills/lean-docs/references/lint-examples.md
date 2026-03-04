# Lint Rule Examples

Examples of encoding "taste" as lint rules with agent-friendly error messages across common tools.

## ESLint (JavaScript/TypeScript)

```json
{
  "rules": {
    "no-restricted-imports": ["error", {
      "patterns": [{
        "group": ["lodash"],
        "message": "Use native array methods instead of lodash."
      }]
    }]
  }
}
```

## Ruff (Python)

```toml
[tool.ruff.lint]
select = ["E", "F", "I", "N"]
[tool.ruff.lint.isort]
known-first-party = ["myproject"]
```

## SwiftLint (Swift)

```yaml
custom_rules:
  no_combine_import:
    name: "No Combine"
    regex: "import Combine"
    message: "Do not use Combine. Use async/await instead."
    severity: error
```

## What makes a good lint rule

- **Error message tells the agent what to do instead** — not just "don't do this" but "do that instead"
- **Catches patterns agents tend to produce** — banned imports, deprecated APIs, wrong framework usage
- **Enforces team taste mechanically** — indent style, naming conventions, file length limits
