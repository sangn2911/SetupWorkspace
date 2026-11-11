---
name: report-work
description: >-
  Vietnamese daily / TASK WORK report from today's commits. Use when the user
  runs /report-work or asks for a daily/work task report.
disable-model-invocation: true
---

# TASK WORK Report Rule

Apply ONLY when the user asks for a daily report, work task report, or TASK WORK report.
Do NOT apply during normal coding, debugging, or Q&A.

## Inputs

- Repo paths the user names (e.g. catalog, catalog-consumer, hsk-user). Resolve each to a local git root.
- Task context from the user (what they intended to work on today). Align Todo/Result wording with that context; use commits as the source of truth for what landed.

## Commit discovery

For each given repo, collect commits that match ALL of:

- Author is `Sang` (name match) OR author email equals `git config user.email` in that repo
- Author-date is **today** in the machine local timezone (`--since=midnight`)
- Prefer the branch the user names; if branch is unclear, search **all branches** with commits by that author today (`git log --all`)
- **Exclude merge commits** always (`--no-merges`; also drop subjects starting with `Merge`)
- **Only important logic commits**: include commits that change or handle application logic (feature, fix, refactor, optimize handlers/CDC/API/consumer, meaningful tracing that supports debugging logic). Skip release/integration merges and other non-logic noise.

Suggested command shape (adapt paths/filters as needed):

```bash
git -C <repo> log --all --no-merges --since=midnight --author='Sang' --pretty=format:'%H %s'
# also acceptable:
git -C <repo> log --all --no-merges --since=midnight --author="$(git -C <repo> config user.email)" --pretty=format:'%H %s'
```

Read subject + short body enough to describe each change in Vietnamese. Deduplicate the same SHA if it appears on multiple branches.

## Commit link template

Build each link from that repo's `origin` remote — do **not** hardcode a full project URL in the rule or the report logic:

1. `base=$(git -C <repo> remote get-url origin)`
2. Strip trailing `.git` and any trailing `/`
3. If `base` is SSH (`git@host:group/project`), convert to `https://host/group/project`
4. Link = `{base}/-/commit/{full_sha}`

Example shape (illustrative SHA only):

`{origin_without_.git}/-/commit/455076564f99af62c5741530b7c3c6f756740fb2`

## Report format (Vietnamese)

Output exactly two sections. Use Vietnamese for all user-facing text. Keep items short and scannable.

```
Todo:
- <mô tả việc làm / nội dung commit, theo context task của user>

Result:
- Hoàn thành:
  + <mô tả>. Git commit: {base}/-/commit/{sha}
  + <mô tả>. Git commit: {base}/-/commit/{sha}
```

Rules for the report:

- `Todo`: `-` bullet list. Summarize the work themes (from user context + commit contents), not raw commit subjects only.
- `Result` → `- Hoàn thành:` then nested `+` lines — one line per relevant commit (or per coherent landed change).
- Each `+` line ends with `Git commit: <url>` using the template above.
- Never list merge commits in Todo or Result.
- Only include important logic-handling commits that count toward the task the user described. If unsure between a logic commit and noise, prefer the logic commit and skip the noise.
- If multiple repos: group or label by repo name in Todo/Result so sources stay clear.
- If no matching commits: say so briefly under Result; still keep the Todo section from user context if they gave one.

## Example

User context: "Hôm nay clean log, fix CDC connection."

```
Todo:
- Dọn log thừa / làm gọn logging
- Sửa lỗi kết nối CDC

Result:
- Hoàn thành:
  + Dọn log consumer CDC. Git commit: https://gitlab.hasaki.work/hasaki-com/backend/hsk-user/-/commit/455076564f99af62c5741530b7c3c6f756740fb2
  + Fix reconnect CDC khi mất connection. Git commit: https://gitlab.hasaki.work/hasaki-com/backend/hsk-user/-/commit/f5feb8854bf9c0118e1be68d4fc22d21da3b037b
```
