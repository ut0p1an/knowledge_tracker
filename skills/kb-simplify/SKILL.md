---
name: kb-simplify
description: Use when the user wants a simplified, condensed version of a knowledge entry - shorter explanation focused on the essentials.
argument-hint: <entry-name>
---

# Knowledge Base - Simplify Entry

## Overview

Rewrite a knowledge entry to its most concise form. Reduces to core essence only.

## Workflow

1. Find and read the target entry file
2. Rewrite it based on type:

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

3. Update the entry file's frontmatter: `level: simplified`
4. Output the simplified version
5. Remind user:
   > 如需恢复详细版本，使用 `/kb-deep {entry}`
