---
name: agent-planning
description: >-
  Plan drafting format: Outline → Explanation → Conclusion with scannable
  lists, English-only plan text, compact file/line outline items. Use when the
  user runs /agent-planning or when drafting/updating an implementation plan.
disable-model-invocation: true
---

# Agent Planning Rule

Apply ONLY when: Plan mode is active, OR you are drafting/updating an implementation plan (including CreatePlan / plan iteration).
Do NOT apply during normal coding, debugging, or Q&A that is not producing a plan.

## Language
- All plan text and planning replies to the user must be English, even if requirements/inputs are Vietnamese (or any other language).

## Listing style (all sections)
- Use any vertically scannable list: `-` bullets, `1. 2. 3.` numbered, or similar.
- Do not force one list marker; choose what fits (ordered work → numbered; unordered points → dots).
- Ban dense paragraphs; each list item is one short, scannable line.

## Required plan skeleton (fixed order)
1. Outline
2. Explanation
3. Conclusion

### Outline
- List the actions to take (any scannable list style).
- Each item is one line: short summary of what to do + impacted file + optional line/range.
- Compact format only (list marker flexible):
  - Add best-seller sort filter — `adapter/es/product_recommend_filter.go` ~14
  - 1. Add best-seller sort filter — `adapter/es/product_recommend_filter.go` ~14
- Prefer real repo paths; include `~line` or `~start–end` when known.
- No prose paragraphs in Outline.

### Explanation
- List how the plan meets the requirements (requirement → approach).
- State why key decisions were taken (defaults, constraints, reuse of existing code).
- Add a mermaid flowchart only when the flow has branches or multiple components; skip diagrams for linear edits.
- Keep items scannable; avoid walls of text.

### Conclusion
- Short list with a summary of intended outcome only (what success looks like after implementation).
- Do not restate the full Outline.
- Do not require assumptions / out-of-scope / risks unless the user asks.

## CreatePlan / Plan mode
- When calling CreatePlan, put Outline → Explanation → Conclusion in the plan body (first line remains the required H1 title).
- On plan iteration, update the same three sections; do not switch layout.
- Todos (if any) should mirror Outline actions one-to-one where practical.

## Sample shape

```markdown
# <Plan title>

## Outline
- <action summary> — `path/to/file.go` ~120
- <action summary> — `path/to/other.go` ~40–60

## Explanation
- <requirement> → <how the plan addresses it>
- <decision> → <why>

## Conclusion
- <intended outcome in 1–2 list items>
```
