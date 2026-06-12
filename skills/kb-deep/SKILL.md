---
name: kb-deep
description: Use when the user wants a comprehensive, in-depth explanation of a knowledge entry - full theory, detailed examples, and extended context.
argument-hint: <entry-name> [direction]
---

# Knowledge Base - Deep Dive

## Overview

Append a new, in-depth section to an existing knowledge entry. Each time this command is used, it adds more detail, allowing for progressive and iterative learning. Optionally accepts a direction hint to focus the deep dive on a specific aspect.

## Argument Parsing

Parse `$ARGUMENTS` to extract:
- **entry name** (required): the knowledge entry to expand
- **direction** (optional): extra description guiding the focus of the new appended section

Examples:
- `/kb-deep decorators` → Appends a new general deep-dive section to the `decorators.md` file.
- `/kb-deep decorators 在类中的应用` → Appends a section focused on decorator usage in classes.
- `/kb-deep cap-theorem 结合实际项目选型` → Appends a section focused on practical system design choices.

## Path Resolution

The knowledge base root (`KB_ROOT`) is:
- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

## Workflow

1.  **Find Entry**: Locate the entry's markdown file via `{KB_ROOT}/search-index.json` (match by `id`, then `title` partial match) and get its `path`. Fallback: scan `{KB_ROOT}/*/` for a matching filename.
2.  **Parse Direction**: Extract the optional `direction` from the arguments.
3.  **Generate New Section**: Create a new markdown section to be appended. This section should be structured as a comprehensive deep dive on the topic, guided by the `direction` if provided. To distinguish multiple deep dives, the new section's title should be unique, e.g., `## 深入探讨 ({{current_date}}) - {direction or Topic}`.
4.  **Append to File**: Read the existing content of the entry's file and append the newly generated section to the end of it. The file should be saved in place.
5.  **Update Index**: After successfully appending the content, update the entry's `lastModified` timestamp in `{KB_ROOT}/search-index.json`.

### Appended Section Structure (Example for "技" entry)

The content generated for the new section should follow a structure similar to the original deep dive, but framed as an additional block of knowledge.

```markdown

---
## 深入探讨 ({{current_date}}) - {Direction/Topic}

### 核心概念回顾
{Briefly recap the core concept in the context of this new deep dive.}

### {Specific Aspect 1}
{Detailed explanation, code examples, etc.}

### {Specific Aspect 2}
{Detailed explanation, code examples, etc.}

### 实践中的考量
{Points to consider when applying this knowledge in real-world scenarios.}

### 关联知识点
- **{Related Topic A}**: {Brief explanation of the connection.}
- **{Related Topic B}**: {Brief explanation of the connection.}
```

The key is that this is an **append-only** operation on the existing file, making the knowledge entry richer over time.


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
