---
name: kb-deep
description: Use when the user wants a comprehensive, in-depth explanation of a knowledge entry - full theory, detailed examples, and extended context.
argument-hint: <entry-name> [direction]
---

# Knowledge Base - Deep Dive

## Overview

Expand a knowledge entry into a comprehensive learning document with full explanations, multiple examples, and contextual connections. Optionally accepts a direction hint to focus the deep dive on a specific aspect.

## Argument Parsing

Parse `$ARGUMENTS` to extract:
- **entry name** (required): the knowledge entry to expand
- **direction** (optional): extra description guiding the focus of the deep dive

Examples:
- `/kb-deep decorators` → full deep dive on decorators
- `/kb-deep decorators 在类中的应用` → deep dive focused on decorator usage in classes
- `/kb-deep cap-theorem 结合实际项目选型` → deep dive focused on practical system design choices

If a direction is provided, adjust the expanded content to emphasize that aspect:
- Weight sections related to the direction more heavily (more examples, more detail)
- Add a dedicated section addressing the direction if it doesn't fit existing sections
- Still include the full structure, but treat the direction as the primary lens

## Workflow

1. Find and read the target entry file
2. Parse direction from arguments (if any)
3. Expand it based on type, focusing on direction when provided:

### For "技" entries — expand to:

```markdown
---
type: 技
level: detailed
---
# {Topic}

## 是什么
{detailed explanation, 2-3 paragraphs}

## 设计动机
{why this technique exists, what problem it solves}

## 使用场景
{3-5 scenarios with context}

## 完整用法

### 基础示例
{annotated code example}

### 进阶示例
{more complex real-world example}

### 与其他技术的配合
{how it integrates with related tools/patterns}

## 内部原理
{how it works under the hood, simplified}

## 最佳实践
- {practice 1 with reason}
- {practice 2 with reason}

## 常见陷阱与解决
| 陷阱 | 原因 | 解决方案 |
|------|------|----------|
| ... | ... | ... |

## 延伸阅读方向
- {next topic 1}
- {next topic 2}
```

### For "道" entries — expand to:

```markdown
---
type: 道
level: detailed
---
# {Topic}

## 概念说明
{thorough explanation, 3-5 paragraphs}

## 历史背景
{when and why this principle emerged}

## 核心思想
{the fundamental insight, explained simply}

## 相关领域
{how this connects to other domains, with explanation}

## 前置知识详解
{brief explanation of each prerequisite}

## 具体实例
{2-3 concrete examples showing the principle in action}

## 常见误解
- {misconception 1}: {correction}
- {misconception 2}: {correction}

## 实践中如何运用
{how to apply this principle in daily coding}

## 进一步学习路径
1. {step 1}: {what to study}
2. {step 2}: {what to study}
3. {step 3}: {what to study}
```

3. **Write to separate file** — save the expanded content to `{entry-name}.detailed.md` in the same directory as the original entry. If the file already exists, overwrite it (supports repeated deep dives that refine the content).
4. Update search-index.json: find the entry by `id`, add `"has_detailed": true`, update `last_updated`
5. Output the expanded version
6. Remind user:
   > 原始条目保持不变。如需精简版本，使用 `/kb-simplify {entry}`
   > 如需指定方向深入，使用 `/kb-deep {entry} <方向描述>`
   > 再次执行 `/kb-deep {entry} [新方向]` 将更新 detailed 版本
