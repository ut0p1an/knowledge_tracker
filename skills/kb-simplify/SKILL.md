---
name: kb-simplify
description: Use when the user wants a simplified, condensed version of a knowledge entry - shorter explanation focused on the essentials.
argument-hint: <entry-name> [direction]
---

# Knowledge Base - Simplify Entry

## Overview

Rewrite a knowledge entry to its most concise form. Reduces to core essence only. Optionally accepts a direction hint to focus the simplification on a specific aspect.

## Argument Parsing

Parse `$ARGUMENTS` to extract:
- **entry name** (required): the knowledge entry to simplify
- **direction** (optional): extra description guiding the focus of the simplification

Examples:
- `/kb-simplify decorators` → general simplified view
- `/kb-simplify decorators 只看语法` → simplified view focused on syntax only
- `/kb-simplify cap-theorem 和数据库的关系` → simplified view focused on database relevance

If a direction is provided:
- Focus the simplified content on the specified aspect
- Tailor the "怎么用" / "关联" sections to emphasize the direction
- Still keep the concise format, but filter through the direction lens

## Path Resolution

The knowledge base root (`KB_ROOT`) is:
- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

## Workflow

1. Find the entry via `{KB_ROOT}/search-index.json` (match by `id`, then `title` partial match) and read the file using its `path` field. Fallback: scan `{KB_ROOT}/*/` for matching filename.
2. Parse direction from arguments (if any)
3. Rewrite it based on type, focusing on direction when provided:

### For "技" entries — simplify to:
```markdown
## 是什么
{one sentence}

## 怎么用
{minimal code example, <10 lines}

## 注意
{1-2 key pitfalls only}
```

### For "道" entries — simplify to:
```markdown
## 一句话
{core concept in one sentence}

## 关联
{related domains, comma-separated}

## 前置
{prerequisites as bullet list}
```

3. **Write to separate file** — save the simplified content to `{entry-name}.simplified.md` in the same directory as the original entry. If the file already exists, overwrite it.
4. Update search-index.json: find the entry by `id`, add `"has_simplified": true`, update `last_updated`
5. Output the simplified version
6. Remind user:
   > 原始条目保持不变。如需详细版本，使用 `/kb-deep {entry}`
   > 如需指定方向精简，使用 `/kb-simplify {entry} <方向描述>`
