---
name: create-work-task
description: >-
  Create or upgrade personal work-task markdown files under .general/tasks/
  with Dashboard, Daily log, Checkpoint (finish order), and Discuss. Optional
  sprint metadata: when provided, stamp sprint in frontmatter and name the file
  SPRINT_<N>_*.md. Jira and Confluence links are optional. Use when the user
  asks to create a task, PO assignment task, work-task file, task dashboard, or
  to upgrade/refactor old .general/tasks/*.md files to work_task v1.
---

# Create / upgrade work-task files

## Paths

- Default output dir: `.general/tasks/` at the workspace (or monorepo) root
- Topic slug: `SCREAMING_SNAKE` from the title (e.g. `CUSTOMER_SERVICE_PAGES`)
- **Sprint is optional.** Behavior depends on whether the user gave a sprint:

| Sprint provided? | Filename | Frontmatter |
|------------------|----------|-------------|
| No | `<TOPIC>.md` | `work_task: v1` only |
| Yes (e.g. 34) | `SPRINT_34_<TOPIC>.md` | `work_task: v1` + `sprint: 34` |

- `<N>` = sprint number with no padding unless the user gives padded form (default: `SPRINT_34_…`)
- Example with sprint: `SPRINT_34_CUSTOMER_SERVICE_PAGES.md`
- Example without: `CUSTOMER_SERVICE_PAGES.md`

Compliance stamp (required at top of every managed file):

```yaml
---
work_task: v1
---
```

With sprint:

```yaml
---
work_task: v1
sprint: 34
---
```

| Frontmatter / name | Action |
|--------------------|--------|
| `work_task: v1`, no sprint, filename `<TOPIC>.md` | Compliant (no-sprint task) |
| `work_task: v1` + `sprint: <N>` + filename `SPRINT_<N>_*.md` | Compliant (sprint task) |
| `sprint` set but filename not `SPRINT_<N>_*` (or reverse mismatch) | Fix meta and/or rename; preserve content |
| Missing, wrong key, or old `work_task` version | Upgrade (see below), then stamp `v1` |
| `work_task: skip` | Leave file untouched |

Current format version: **v1**.

## When to run

- **Create:** user asks for a new task / PO assignment / tracked work file
- **Upgrade:** user asks to upgrade tasks, or the work-task rule detects a non-compliant `.general/tasks/*.md` file in scope

Do not start implementing product code unless the user explicitly asks after the file exists.

## Create workflow

1. Collect inputs:
   - Title / goal (**required**)
   - Sprint number (**optional**) — only if the user provides it; do not ask solely for sprint
   - Finish order (tickets or work items). If multiple items and no order → ask once
   - Jira URLs and/or Confluence URLs (optional)
   - Free-form notes, acceptance criteria, design links
2. If Jira/Confluence URLs are present → fetch and summarize into Checkpoint + Links.
   If absent → scaffold from notes only; put gaps in Discuss (do not block file creation).
3. Choose path:
   - With sprint → `.general/tasks/SPRINT_<N>_<TOPIC>.md`
   - Without → `.general/tasks/<TOPIC>.md`
4. Write using the **Required sections** template.
5. Stamp frontmatter: always `work_task: v1`; add `sprint: <N>` only when provided.
6. If sprint provided → include `**Sprint:** <N>` in the visible meta block.
7. Add a Daily log row for today: what was created / next action.
8. Reply with the file path and the next action (usually: resolve open Discuss rows, then start first Checkpoint item).

## Upgrade workflow

Goal: same v1 shape; **preserve existing content** (wording, checklists, links, decisions).

1. Read the full file. If `work_task: skip` → stop.
2. If already compliant for its sprint mode → stop unless user forced a rewrite.
3. Map old content:
   - Title / status / links → header meta
   - Existing checklists / phases / backlog → Checkpoint (keep done/undone as-is)
   - Progress tables → Dashboard rows
   - Open questions → Discuss rows
   - Leftover prose that does not fit → `## Legacy notes` (do not delete)
4. Sprint (only when already present or user supplies it now):
   - If frontmatter/body has a sprint → keep it and ensure filename is `SPRINT_<N>_<TOPIC>.md`
   - Else if filename is already `SPRINT_<N>_…` → set `sprint: <N>` to match
   - Else → leave as no-sprint (`<TOPIC>.md`, no `sprint` key). Do **not** invent a sprint.
5. Infer finish order only when the file already states one; otherwise one Discuss row: “Confirm finish order”.
6. Do **not** mark items done unless the old file already indicated done.
7. Do **not** invent Jira keys, owners, progress, or sprint numbers.
8. Write the upgraded file with `work_task: v1` (+ `sprint` only if applicable); rename when the name must change (use `git mv` if tracked).
9. Short reply: old path → new path (if renamed), what moved where, any Discuss items that need the user.

## Required sections (v1)

Order matters. After frontmatter:

1. `#` title  
2. Meta lines (`**Status:**`, `**Last updated:**`, `**Sprint:**` only if sprint set, optional assignee/PO/repo/links)  
3. Finish-order table or list when there are multiple work items  
4. `## Dashboard (daily self-check)` — status table + state legend  
5. `### Daily log` — date / focus / done today / blocked or next  
6. `## Checkpoint (keep history; do not delete done rows)` — ordered work; checkboxes  
7. `## Discuss (open questions)` — table; keep resolved rows  
8. Optional: `## Spec snapshot`, `## Links`, `## Next action`, `## Legacy notes`

### Dashboard states

`⬜ Todo` · `🔄 In progress` · `✅ Done` · `⛔ Blocked` · `❓ Clarify`

### Discuss table columns

`#` | `Question` | `Asked to` | `Status` | `Answer / decision`

## Template (with sprint)

```markdown
---
work_task: v1
sprint: 34
---

# <Title>

**Status:** Not started  
**Last updated:** YYYY-MM-DD  
**Sprint:** 34  

**Finish order:** <A → B → C>   <!-- omit if single item -->

| # | Item | Ref |
|---|------|-----|
| 1 | … | optional URL |

---

## Dashboard (daily self-check)

| Item | State | Notes / how to verify |
|------|--------|------------------------|
| Overall | Not started | |
| Current item | — | Next unfinished in finish order |
| <Item A> | ⬜ Todo | |
| Open blockers | 0 | Discuss # |

**States:** `⬜ Todo` · `🔄 In progress` · `✅ Done` · `⛔ Blocked` · `❓ Clarify`

### Daily log

| Date | Focus | Done today | Blocked / next |
|------|-------|------------|----------------|
| YYYY-MM-DD | — | Task file created | … |

---

## Checkpoint (keep history; do not delete done rows)

### 1 — <First item>

- [ ] …

### 2 — <Second item>

- [ ] …

---

## Discuss (open questions)

| # | Question | Asked to | Status | Answer / decision |
|---|----------|----------|--------|-------------------|
| 1 | … | … | Open | |

---

## Links

- …

---

## Next action

1. …
```

Without sprint: omit the `sprint:` frontmatter key, omit `**Sprint:**`, and use filename `<TOPIC>.md`.

## Jira / Confluence (optional)

- Present → fetch; fill Checkpoint from acceptance criteria; Links from URLs; unknowns → Discuss.
- Absent → still create a complete v1 file from user notes.
- Never refuse to create a task only because tickets or sprint are missing.

## Finish order

- Honor the user’s explicit order; do not reorder by product “natural” flow.
- Record the order in meta + Checkpoint numbering.
- Single-item tasks: skip the finish-order table.

## Migrate this skill

Personal copies live at:

- `~/.cursor/skills/create-work-task/SKILL.md`
- `~/.cursor/rules/work-task.mdc`

Copy both to the same paths on another machine.
