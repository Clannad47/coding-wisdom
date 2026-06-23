# Distillation Guide

Use this guide only when the user asks to distill, organize, review, or move captured entries from `inbox/` into `references/`.

## Core Rule

Research before moving. Do not treat `mv inbox/... references/...` as distillation.

Distillation means turning project-specific details into reusable engineering judgment, then validating that judgment with comparison, external calibration, and operational rules.

## Workflow

1. Quick check: `grep -rl "disposition: rejected" inbox/low/` — 展示本周被门禁拒绝的条目摘要，询问用户是否有误杀需捞回。
2. Browse `inbox/high/`.
3. Cluster related entries by theme.
4. Pick 3-5 entries worth deep work. Do not try to empty the whole inbox.
5. For each selected entry, identify the core technical concept to research.
6. Do at least one web search per selected entry when current external practice matters.
7. Strengthen `## 泛化` until it reaches at least level 3 in `guides/generalization.md`.
8. Add or update `## 联网校准` using `guides/web-calibration.md`.
9. Add a diagram when structure, lifecycle, ownership, or data flow is central; use `guides/ascii-diagrams.md`.
10. Check the quality gate below.
11. Move only passing entries into the right `references/` directory.
12. Update the target `_index.md` — this is the single source of truth.
13. Run the sync script to regenerate `OVERVIEW.md`:
    - `bash scripts/sync-overview.sh` (macOS/Linux/Git Bash)
    - `powershell -ExecutionPolicy Bypass -File scripts/sync-overview.ps1` (Windows)
14. Verify: `git diff OVERVIEW.md` shows the expected additions.

## Quality Gate

Each high-value entry moved into `references/` should satisfy at least 3 of these:

- Contains a comparison structure: good vs bad, before vs after, or pattern A vs pattern B.
- Names at least one anti-pattern.
- Contains an operational rule: when a future signal appears, what check should be performed.
- Has a `## 联网校准` section with at least one authoritative external source.
- Uses an insight title, not a topic title.
- Includes a self-contained ASCII diagram when a diagram materially improves understanding.

## Full Entry Shape

Use `templates/distilled-entry.md` as the target shape. Do not require every section to be long; require every section to do real work.

## Staleness Check

陈旧标记由 `scripts/cleanup.sh` (bash) 或 `scripts/cleanup.ps1` (PowerShell) 自动完成——脚本在超过 90 天的条目 frontmatter 中添加 `stale: true`。

蒸馏时，检索已标记条目：

```bash
grep -rl '^stale: true' references/
```

也可以通过 `find` 确认：

```bash
find references/ -name "*.md" -not -name "_index.md" -mtime +90
```

将陈旧条目展示给开发者，询问是更新、合并还是删除。处理完成后移除 `stale: true` 行。

## Anti-Patterns

| Anti-pattern | Better action |
| --- | --- |
| Processing 30 inbox entries shallowly | Deep-process 3-5 entries |
| Moving files as the definition of done | Move only after the quality gate passes |
| Writing one generic sentence under `## 泛化` | Reach pattern, principle, and operational rule levels |
| Trusting the original intuition | Use external calibration to verify or correct it |
| Emptying inbox as the goal | Increasing judgment quality as the goal |

## Lifecycle

```text
coding -> capture -> inbox -> research -> generalize + calibrate -> quality gate -> references -> reuse
                                           ^_______________________________________________|
                                                          reuse surfaces new gaps
```
