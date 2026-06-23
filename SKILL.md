---
name: coding-wisdom
description: 从编码会话中捕获认知裂缝，蒸馏为开发者的通用能力。当识别到重构、bug修复、模式复现、方案选择、技术研究等认知裂缝时自动触发。
---

# Coding Wisdom

从编码会话中自动捕获认知裂缝，并在开发者有空时把它们蒸馏成可复用的工程判断。

核心哲学：蒸馏不是归档。蒸馏是把项目细节转化为通用原则，并用外部知识、对比结构和可操作规则校准它。文件移动只是最后的副作用。

## 目录结构

```text
coding-wisdom/
├── SKILL.md              # 触发规则、捕获协议、动态加载路由
├── guides/               # 低频深流程，按需加载
├── templates/            # 捕获和蒸馏条目模板
├── inbox/                # 捕获区，本地个人数据
│   ├── high/
│   └── low/
├── references/           # 蒸馏后的个人知识库，本地个人数据
└── OVERVIEW.md           # 由 scripts/sync-overview.sh 自动生成，禁止手动编辑
```

## 动态加载

只在需要时读取额外文件：

- 捕获新裂缝：读取 `templates/capture-entry.md`。
- 用户要求蒸馏、整理 inbox、移动到 references：读取 `guides/distillation.md` 和 `templates/distilled-entry.md`。
- 需要补强泛化质量：读取 `guides/generalization.md`。
- 需要联网研究或校准洞察：读取 `guides/web-calibration.md`。
- 需要补图或判断图是否合格：读取 `guides/ascii-diagrams.md`。

不要在普通编码捕获阶段加载蒸馏 guide。

## 捕获规则

当以下事件发生时，往 `inbox/` 写入一条知识（tier 由通用性门禁最终决定）：

1. 重构：执行了结构性重构，例如数据结构变更、模块拆分、架构调整。
2. Bug 修复：修复了非平凡 bug，例如逻辑错误、设计缺陷。
3. 模式复现：在不同项目或模块中识别到相似模式。
4. 方案选择：在多个实现方案中做了选择，且被放弃的方案有合理理由。
5. 技术研究：完成技术研究，产出非文档直接结论。

## 噪音过滤

以下情况不捕获：

- 纯格式化改动，例如缩进、空行、import 排序。
- 简单重命名，例如变量名、函数名。
- 配置文件修改，例如版本号、端口号。
- 测试文件的 mock 调整。

## 通用性门禁（路由，非拦截）

噪音过滤之后、写入 inbox 之前，逐项确认。门禁不判死刑，只决定条目去向：

**Q1 双场景测试**: 能在至少一个其他场景/项目/技术栈中找到此洞察的适用场景吗？
**Q2 去项目化测试**: 去掉项目名、模块名、文件名后，洞察仍成立吗？

两项任一通过 → 继续判断初见或复现 → 决定 tier。
两项都不通过 → `inbox/low/`，frontmatter 标记 `disposition: rejected`，7 天后自然淘汰。

**初见 vs 复现**: Q1 或 Q2 通过后，判断这是第几次见到此模式。
- 第 1 次 → `low`，标记 `disposition: first_sight`。
- 第 2+ 次 → `high`，标记 `disposition: recurrence`，无论之前门禁结果如何。

**复现检测**: 捕获新条目时，检查 `inbox/low/` 中 `disposition: rejected` 条目是否有同主题的。第二次出现时，新条目升级为 `high`（`disposition: recurrence`），旧条目在 frontmatter 中追加 `overturned: true`（保留在 low 等自然过期）。

**被拒条目透明**: `disposition: rejected` 的条目留在 `low/`。用 `grep -rl "disposition: rejected" inbox/low/` 审计什么差点污染知识库，据此校准门禁规则。

## 捕获流程

1. 判断触发类型。
2. 通过噪音过滤。
3. 通过通用性门禁 → 决定 tier。
4. 生成文件名：`{YYYY-MM-DD}_{fix|learn}_{对象描述}.md`。
   - `fix`：以前理解错了，现在修正。
   - `learn`：以前不知道，现在知道了。
5. 写入 `inbox/{tier}/`。
6. 使用 `templates/capture-entry.md`，frontmatter 中填写门禁结果。
7. 写入后检查同目录是否有相关条目；如有，在 frontmatter 的 `links` 中关联。

## 捕获格式

- 文件名：`{date}_{fix|learn}_{对象}.md`
- 模板：`templates/capture-entry.md`
- 位置：`inbox/{tier}/`
- 保留期：`high` 永不过期，`low` 默认 7 天后可清理。

## 自清洁

清理脚本：

- `bash scripts/cleanup.sh` (macOS / Linux / Git Bash)
- `powershell -ExecutionPolicy Bypass -File scripts/cleanup.ps1` (Windows)

两个触发点，均静默执行，不提醒不确认：

1. **会话启动**（skill 加载时）：自动跑一次。low 过期条目直接删除，references 过期条目标记 `stale: true`。完事后一句带过，不追问。
2. **蒸馏前**：先跑一次，确保 stale 标记是最新的，再开始挑条目。

脚本逻辑：
- 删除 `inbox/low/` 中超过 7 天的条目。
- 在 `references/` 中超过 90 天未更新的条目 frontmatter 中添加 `stale: true`（已标记则跳过）。

## 索引维护

`_index.md` 是单一事实源。`OVERVIEW.md` 由 sync 脚本自动生成，禁止手动编辑。

蒸馏阶段写入或修改 `references/` 条目后：
1. 更新目标目录的 `_index.md`（这是你唯一需要手动改的文件）。
2. 运行 sync 脚本重新生成 `OVERVIEW.md`：
   - macOS / Linux / Windows Git Bash: `bash scripts/sync-overview.sh`
   - Windows PowerShell: `powershell -ExecutionPolicy Bypass -File scripts/sync-overview.ps1`

远端保留初始版模板；本地私改 `_index.md` 和 `OVERVIEW.md` 后应使用 `git update-index --skip-worktree` 避免把个人内容提交到云端。

## 开发者工作流

捕获应低摩擦，能在 30 秒内写完。蒸馏应低频高质量，只有当 `inbox/high/` 有足够材料、且开发者明确要整理时才启动。

使用本 skill 时：

- 正常编码时，只做捕获判断和最小条目写入。
- 蒸馏时，先读 `guides/distillation.md`，再处理文件移动和索引更新。
- 复用知识时，按当前问题检索 `references/`，不要预读整个知识库。

## 与现有系统的关系

- `CLAUDE.md` / `AGENTS.md`：项目级约束和工作流规则。
- `MEMORY.md` / `.codex/memories/`：跨会话上下文记忆。
- `lessons`：项目级错题集。
- `coding-wisdom`：跨项目的个人工程判断增长系统。
