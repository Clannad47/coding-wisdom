---
name: coding-wisdom
description: 从编码会话中捕获认知裂缝，蒸馏为开发者的通用能力。当识别到重构、bug修复、模式复现、方案选择、技术研究等认知裂缝时自动触发。
triggers:
  - type: refactor
    tier: high
    condition: "agent 执行了结构性重构"
  - type: bugfix
    tier: high
    condition: "agent 修复了一个非平凡的 bug"
  - type: pattern
    tier: high
    condition: "在不同项目/模块中识别到相似模式"
  - type: decision
    tier: low
    condition: "agent 在多个方案中做了选择，且被放弃的方案有合理理由"
  - type: research
    tier: low
    condition: "agent 完成技术研究，产出非文档直接结论"
ignore_rules:
  - "纯格式化改动（缩进、空行、import 排序）"
  - "简单重命名（变量、函数名）"
  - "配置文件修改（版本号、端口号）"
  - "测试文件的 mock 调整"
capture_format:
  filename: "{date}_{fix|learn}_{对象}.md"
  template: "crack"
  location: "inbox/{tier}/"
auto_expire:
  high: never
  low: 7d
---

# Coding Wisdom

## 这是什么

一个从编码会话中自动捕获认知裂缝的系统。
你在编码时学到的东西会被 agent 零摩擦地记录下来，
等你有空的时候再做深度消化。

## 目录结构

```
coding-wisdom/
├── SKILL.md              # 本文件：agent 指令 + 开发者指南
├── inbox/                # 捕获区
│   ├── high/             # 高价值裂缝，永不过期，开发者必看
│   └── low/              # 低价值裂缝，7 天后自动消失
├── references/           # 蒸馏后的知识库
│   ├── architecture/     # 架构认知
│   ├── coding/           # 编码技巧
│   ├── mindset/          # 思维方式
│   └── techstack/        # 技术栈认知
└── OVERVIEW.md           # 全局知识地图
```

## Agent 指令

### 捕获规则

当以下事件发生时，往 inbox/ 写入一条知识：

1. **重构**（high）— 执行了结构性重构（数据结构变更、模块拆分、架构调整）
2. **Bug 修复**（high）— 修复了一个非平凡的 bug（逻辑错误、设计缺陷）
3. **模式复现**（high）— 在不同项目或模块中识别到相似模式
4. **方案选择**（low）— 在多个实现方案中做了选择，被放弃的方案有合理理由
5. **技术研究**（low）— 完成技术研究，产出非文档直接结论

### 噪音过滤

以下情况不捕获：
- 纯格式化改动（缩进、空行、import 排序）
- 简单重命名（变量、函数名）
- 配置文件修改（版本号、端口号）
- 测试文件的 mock 调整

### 写入流程

1. 判断触发类型和 tier（high/low）
2. 生成文件名：`{YYYY-MM-DD}_{fix|learn}_{对象描述}.md`
   - `fix`：以前理解错了，现在修正
   - `learn`：以前不知道，现在知道了
3. 写入 `inbox/{tier}/` 目录
4. 使用条目模板（见下方）
5. 写入后，检查同目录是否有相关条目，如有则在 frontmatter 的 links 中关联

### 条目模板

```markdown
---
trigger: "触发事件描述"
crack: "fix 或 learn"
links:
  - path/to/related.md
created: YYYY-MM-DD
---

# 标题即洞察（一句话概括认知裂缝）

## 我以为
（你之前的理解，一两句话）

## 其实是
（你现在的理解，一两句话）

## 背景
（项目名 + 阶段 + 场景描述，自然语言）

## 泛化（蒸馏时补充）
（从项目细节到通用原则）
```

### _index.md 维护

当往某个 references/ 子目录写入或修改条目时，
顺便更新该目录的 `_index.md`，保持 3-5 句话的领域认知快照。

### 衰减检查

在蒸馏阶段，运行以下命令找出超过 90 天未更新的条目：
```bash
find references/ -name "*.md" -not -name "_index.md" -mtime +90
```
将结果展示给开发者，由开发者决定：更新、合并、或删除。

---

## 开发者指南

### 怎么蒸馏

建议每周花 15 分钟做一次蒸馏：

1. 浏览 `inbox/high/`，按标题挑选 2-3 条值得深入的
2. 给每条补充 `泛化` 节 — 从项目细节抽象到通用原则
3. 移入 `references/` 对应目录
4. agent 会自动更新目标目录的 `_index.md`
5. 审视 `inbox/low/` 中剩余的条目，有价值的提升到 high
6. 删除不再需要的条目

### 怎么利用

- 在新项目中，agent 会自动检索 `references/` 中的知识
- 你也可以手动浏览 `references/` 来复习
- `OVERVIEW.md` 展示你的知识版图全貌

### 知识的生命周期

```
编码 → agent 捕获 → inbox → 蒸馏 → references → 复用 → 新捕获
```

### 与现有系统的关系

- `CLAUDE.md` → 人格 + 工作流约束（不冲突）
- `MEMORY.md` → 跨会话上下文（不冲突）
- `lessons` → 项目级错题集（互补：lessons 是项目级，coding-wisdom 是全局级）
- `coding-wisdom` → 开发者能力增长引擎
