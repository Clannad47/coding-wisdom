# Generalization Guide

Use this guide when an entry's `## 泛化` section is weak, too project-specific, or not actionable.

## Four Levels

```text
Level 1: Phenomenon
  "In this project, X happened."

Level 2: Pattern
  "This is an instance of Y pattern."

Level 3: Principle
  "Any system with Z properties should..."

Level 4: Operational rule
  "Next time signal W appears, run this checklist."
```

An entry should reach at least level 3 before moving into `references/`. Level 4 is the target for high-value entries.

## How To Improve A Weak Entry

Ask these questions:

1. What concrete misunderstanding changed?
2. What recurring structure does this reveal?
3. What kind of system will hit this problem again?
4. What early signal should trigger this memory?
5. What should a future engineer inspect or avoid?

## Output Shape

Prefer this structure:

```markdown
## 泛化

### 现象
...

### 模式
...

### 原则
...

### 可操作规则
- 当看到 ... 时，检查 ...
- 不要 ...
```

Keep the section concise. The goal is transferability, not a longer essay.
