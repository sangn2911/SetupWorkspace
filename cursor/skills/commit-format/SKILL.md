---
name: commit-format
description: >-
  Hasaki commit message format: subject line, blank line, and func line. Use
  when the user runs /commit-format or asks to create a commit with the team
  format.
disable-model-invocation: true
---

# Commit message format

Every commit message is a subject line, a blank line, and a `func` line. No description paragraph. No `Co-authored-by` trailer.

```
refactor: share the identifier PII row type helper

func: GET_USER
```

- Subject is one line: `type: summary`.
- `func` is the feature name in uppercase, for example `GET_USER` or `LANDING_PAGE`.
- Commit with `FUNC=<NAME> TASK= SKIP_LINT=1`.
- Do not add a body or a co-author trailer. If a trailer is inserted, rewrite the message so only the subject and `func` line remain.
