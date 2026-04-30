# Coding Wisdom

> 一个 Claude Code skill：从编码会话中自动捕获认知裂缝，蒸馏为你的通用工程能力。

你和 AI agent 一起写代码的时候，每天都在学到新东西——一个反直觉的设计决策、一个踩过的坑、一个比你方案更好的实现。

但这些洞察在编码结束后就消失了。

**Coding Wisdom 帮你留住它们。**

## 它怎么工作

```
你编码 → agent 识别认知裂缝 → 零摩擦写入 inbox
                ↓
        你有空时浏览 inbox → 蒸馏为通用原则 → 存入 references
                ↓
        下次编码 → agent 检索 references → 你复用旧知识
                ↓
            你变得更强了
```

三个关键词：**零摩擦捕获**、**异步蒸馏**、**循环复用**。

## 安装

### 方式一：手动复制

把整个 `coding-wisdom` 文件夹复制到你的 Claude Code skills 目录：

```bash
# macOS / Linux
cp -r coding-wisdom ~/.claude/skills/

# Windows
xcopy /E /I coding-wisdom %USERPROFILE%\.claude\skills\coding-wisdom
```

### 方式二：git clone

```bash
cd ~/.claude/skills
git clone https://github.com/your-username/coding-wisdom.git
```

安装完成后，重启 Claude Code，你就能在 skills 列表里看到 `coding-wisdom`。

## 快速开始

### 1. 正常编码

不需要做任何特别的事。就像平时一样和 agent 一起写代码。

### 2. agent 自动捕获

当 agent 遇到以下情况时，它会自动往 `inbox/` 里写一条知识：

| 事件 | 优先级 | 例子 |
|------|--------|------|
| 结构性重构 | high | 重命名核心数据结构、拆分模块 |
| Bug 修复 | high | 修复逻辑错误、设计缺陷 |
| 模式复现 | high | 在不同项目里看到相似的设计模式 |
| 方案选择 | low | 在 A 和 B 之间选了 A，放弃 B 有理由 |
| 技术研究 | low | 深入研究了一个技术点，得到非显然结论 |

你不需要确认或批准——它就这么发生了。

### 3. 蒸馏（建议每周 15 分钟）

```bash
# 看看 inbox 里有什么
ls ~/.claude/skills/coding-wisdom/inbox/high/
```

挑 2-3 条感兴趣的，打开它们，补充「泛化」节——把项目细节抽象成通用原则。然后移到 `references/` 对应目录。

### 4. 自动复用

下次编码时，agent 会自动检索 `references/` 里的知识。当它发现你当前的问题和之前学过的东西有关，它会提醒你。

## 目录结构

```
coding-wisdom/
├── SKILL.md                # agent 指令 + 开发者指南
├── README.md               # 你正在读的文件
├── OVERVIEW.md             # 你的知识版图全貌
├── inbox/                  # 捕获区（等待蒸馏）
│   ├── high/               #   高价值，永不过期
│   └── low/                #   低价值，7 天后自动消失
└── references/             # 知识库（蒸馏后）
    ├── architecture/       #   架构认知
    │   ├── _index.md       #     领域认知快照
    │   ├── data-flow/      #     数据流设计
    │   └── system-design/  #     系统设计模式
    ├── coding/             #   编码技巧
    │   ├── _index.md
    │   └── python/         #     Python 惯用法
    ├── mindset/            #   思维方式
    │   └── _index.md
    └── techstack/          #   技术栈认知
        ├── _index.md
        └── llm/            #     LLM 应用
```

## 知识条目长什么样

每条知识都是一个 markdown 文件：

```markdown
---
trigger: "重构 PipelineContext 时发现的"
crack: "fix"
links:
  - architecture/data-flow/declarative-persist.md
created: 2026-04-30
---

# TypedDict 是声明式契约，不是类型标注

## 我以为
TypedDict 只是给 dict 加类型提示的工具。

## 其实是
TypedDict 让数据结构成为自文档化的契约，
每个处理步骤都声明自己需要什么、产出什么。

## 背景
Insurance Atom Trigger 项目，Pipeline 重构阶段。
多步骤数据流需要跨步骤的类型一致性保障。

## 泛化
任何多步骤数据处理系统都应该考虑声明式类型契约。
```

就这些。「我以为」和「其实是」是核心。「泛化」是蒸馏时补充的。

## 文件命名规则

```
{日期}_{fix或learn}_{对象描述}.md
```

- `fix` — 以前理解错了，现在修正
- `learn` — 以前不知道，现在知道了

例子：
- `2026-04-30_fix_typeddict是契约不是标注.md`
- `2026-04-30_learn_blake2b的digest_size选择.md`

文件名就是索引。看到名字就知道这条知识讲什么。

## 知识的四个维度

`references/` 按认知维度组织，你可以根据需要添加或调整：

| 维度 | 关注什么 | 例子 |
|------|----------|------|
| architecture | 系统设计、模块边界、数据流 | 声明式持久化、热重载模式 |
| coding | 语言惯用法、编码模式、反模式 | TypedDict vs dict、哨兵值 |
| mindset | 设计哲学、好品味、思维模型 | 消除特殊情况、简洁执念 |
| techstack | 具体技术栈的深度理解 | Kafka rebalance、LLM tool use |

每个维度目录下有一个 `_index.md`，是这个领域的认知快照——3-5 句话概括你目前的理解。

## 衰减机制

知识不会自动过期，但会被标记为"陈旧"。

当一条知识超过 90 天没有被修改也没有被引用时，agent 会在蒸馏阶段提醒你审视它：

- 还有价值？更新它
- 被更好的理解取代了？合并或删除
- 太冷门？删除

知识应该在迭代中变少、变精，不是越来越多。

## 自定义

### 添加新的认知维度

```bash
mkdir -p ~/.claude/skills/coding-wisdom/references/your-dimension
```

在目录里创建 `_index.md`，写 3-5 句话描述这个维度关注什么。

### 修改触发规则

编辑 `SKILL.md` 的 frontmatter 部分。`triggers` 定义了什么事件触发捕获，`ignore_rules` 定义了什么噪音需要过滤。

### 修改过期时间

`SKILL.md` 的 frontmatter 里 `auto_expire.low` 控制低优先级条目的过期天数。默认 7 天。

## 设计哲学

这个 skill 基于几个核心信念：

1. **认知裂缝 > 信息增量** — 记录你理解错误的瞬间，不是你第一次见到的 API
2. **零摩擦 > 完美格式** — 30 秒能写完的才是好的捕获
3. **关系 > 分类** — 用具体的 links 连接知识，不要纠结于把它放进哪个盒子
4. **变少 > 变多** — 好的知识系统在迭代中变得更精炼，不是更臃肿
5. **文件名即索引** — 看到名字就知道内容，不需要打开文件

## FAQ

**Q: 这和 CLAUDE.md / MEMORY.md 有什么区别？**

- `CLAUDE.md` 是项目的架构约束和工作流规则
- `MEMORY.md` 是跨会话的上下文记忆
- `coding-wisdom` 是你的通用能力增长引擎——从所有项目中汲取养分

**Q: inbox 会不会堆积太多噪音？**

high tier 只在真正有价值的事件触发。low tier 7 天自动消失。你不需要手动清理。

**Q: 我需要每天蒸馏吗？**

不需要。建议每周 15 分钟。甚至每月一次也行。inbox 里的 high tier 不会过期，你可以按自己的节奏来。

**Q: 可以和团队共用吗？**

当前设计是单人使用。多人场景需要解决知识所有权和冲突的问题，暂未支持。

**Q: 能不能自动蒸馏？**

蒸馏的核心动作是"从项目细节抽象到通用原则"——这需要人类的判断力。agent 可以辅助，但不能替代。

## 许可证

MIT
