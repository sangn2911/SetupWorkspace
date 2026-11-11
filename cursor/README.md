# Cursor rules and skills

Migration mirror for a new device. Cursor does **not** load this folder.
Install by copying into `~/.cursor/`.

## Layout

```
cursor/
  rules/
    code_style_rules.mdc   # sole always-on rule
  skills/
    report-work/SKILL.md   # /report-work
    gen-http/SKILL.md      # /gen-http
    gen-es/SKILL.md        # /gen-es
    agent-planning/SKILL.md # /agent-planning
    commit-format/SKILL.md # /commit-format
```

## Install on a new device

```bash
# Always-on rule
mkdir -p ~/.cursor/rules
cp -f rules/code_style_rules.mdc ~/.cursor/rules/

# Slash skills
mkdir -p ~/.cursor/skills
cp -a skills/. ~/.cursor/skills/
```

Do **not** paste these into Settings → User Rules. That duplicates skills/rules.

## How to use skills

In Agent chat, type `/` and pick a skill (e.g. `/report-work`, `/gen-es`).
Skills use `disable-model-invocation: true`, so they load only when invoked via `/` or `@`.

## Settings User Rules cleanup

After install, open Cursor Settings → Rules → User Rules and **remove** any blocks that duplicate:

- Code Style Rules
- Agent Planning Rule
- Commit / ElasticVue / TASK WORK content now covered by skills or `code_style_rules.mdc`

Keep unrelated User Rules (e.g. git safety, PR creation) if you still want them.

## Sole always-on rule

Only `code_style_rules.mdc` stays as an always-applied rule under `~/.cursor/rules/`.
Everything else is a slash skill under `~/.cursor/skills/`.
