---
name: kb-delete
description: Use when the user wants to delete a knowledge entry from their knowledge base, remove a collected knowledge point they no longer need.
argument-hint: <entry-name>
---

# Knowledge Base - Delete Entry

## Overview

Delete a specific knowledge entry and update all index files.

## Workflow

1. Parse `$ARGUMENTS` as entry name
2. Find the entry file in `~/.claude/knowledge/`
3. Confirm with user before deleting:
   > 确认删除「{entry name}」（{type}/{category}）？[Y/n]
4. On confirmation:
   - Delete the entry `.md` file
   - Remove entry from `~/.claude/knowledge/{技|道}/{category}/_catalog.md`
   - Remove entry from `~/.claude/knowledge/INDEX.md`
   - Remove entry from `~/.claude/knowledge/search-index.json`:
     - Read the JSON, filter out the entry by `id` from the `entries` array
     - Also remove this `id` from any other entry's `related` array
     - Update `last_updated` to current date
     - Write back
   - Update profile.md if needed (remove from 待学习 if present)
5. Output:
   > 已删除「{entry name}」

## If Not Found

> 未找到「{query}」相关条目。使用 `/kb-list` 查看所有条目。

## Batch Delete

If user provides multiple names separated by comma or space:
- List all matches
- Confirm once for all
- Delete all confirmed entries
