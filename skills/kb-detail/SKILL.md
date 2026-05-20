---
name: kb-detail
description: Use when the user wants to view the full content of a specific knowledge entry, read a collected knowledge point in detail.
argument-hint: <entry-name>
---

# Knowledge Base - Detail View

## Overview

Load and display the full content of a specific knowledge entry.

## Workflow

1. Parse `$ARGUMENTS` as entry name (supports partial match)
2. Search in `~/.claude/knowledge/技/` and `~/.claude/knowledge/道/` for matching file
3. Read and display the full entry content
4. If multiple matches, show list and ask user to choose

## Search Logic

1. Exact filename match (without .md extension)
2. Partial match in filename
3. Search in `_catalog.md` descriptions for keyword match

## If Not Found

> 未找到「{query}」相关条目。使用 `/kb-list` 查看所有条目。

## Display

Show the full markdown content of the entry file as-is. After display, remind:
- `/kb-simplify <entry>` — 精简版本
- `/kb-deep <entry>` — 深入讲解
- `/kb-delete <entry>` — 删除此条目
