---
name: kb-detail
description: Use when the user wants to view the full content of a specific knowledge entry, read a collected knowledge point in detail.
argument-hint: <entry-name>
---

# Knowledge Base - Detail View

## Overview

Load and display the full content of a specific knowledge entry, including its linked entries.

## Path Resolution

The knowledge base root (`KB_ROOT`) is:
- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

## Workflow

1. Parse `$ARGUMENTS` as entry name (supports partial match)
2. Try to search in `{KB_ROOT}/search-index.json` first:
   - Match against `id` (exact), then `title` (partial), then `tags` (contains), then `summary` (keyword)
   - If found, use the `path` field to read the entry file directly
3. If search-index.json doesn't exist or no match found, fall back to directory search:
   - Search in all subdirectories of `{KB_ROOT}/` for matching `.md` files (skip INDEX.md, profile.md, and non-entry files)
4. Read and display the full entry content
5. Display linked entries section
6. If multiple matches, show list with summaries (from index if available) and ask user to choose

## Search Priority (when using index)

1. Exact `id` match (e.g., "decorators" matches id "decorators")
2. Partial `title` match (e.g., "装饰" matches title "Python 装饰器")
3. `tags` contains match (e.g., "元编程" found in tags array)
4. `summary` keyword match (e.g., "@语法" found in summary text)

## Fallback Search Logic (without index)

1. Exact filename match (without .md extension) in `{KB_ROOT}/*/`
2. Partial match in filename across all category directories

## If Not Found

> 未找到「{query}」相关条目。使用 `/kb-list` 查看所有条目。

## Display

Show the full markdown content of the entry file as-is. The top part of the file serves as the simplified summary, and the rest is the detailed content.

### Linked Entries Section

After the main content, if the entry has `related` entries in search-index.json (or `links` in frontmatter), display:

```
🔗 关联条目:
• {linked-id} [{type}/{category}] — {summary}
• {linked-id} [{type}/{category}] — {summary}
```

Read linked entries' metadata from search-index.json to show type, category, and summary.

### Actions Reminder

After display, remind:
- `/kb-deep <entry> [方向]` — 追加深入讲解（可指定方向）
- `/kb-delete <entry>` — 删除此条目
- `/kb-link <entry> <other>` — 关联其他条目
