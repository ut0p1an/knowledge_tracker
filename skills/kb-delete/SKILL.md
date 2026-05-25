---
name: kb-delete
description: Use when the user wants to delete a knowledge entry from their knowledge base, remove a collected knowledge point they no longer need.
argument-hint: <entry-name>
---

# Knowledge Base - Delete Entry

## Overview

Delete a specific knowledge entry and clean up all references including bidirectional links.

## Path Resolution

The knowledge base root (`KB_ROOT`) is:
- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

## Workflow

1. Parse `$ARGUMENTS` as entry name
2. Find the entry in `{KB_ROOT}/search-index.json` (or scan `{KB_ROOT}/*/` as fallback)
3. Confirm with user before deleting:
   > 确认删除「{entry name}」（{type}/{category}）？[Y/n]
4. On confirmation:
   - Delete the entry `.md` file
   - Delete `{entry}.detailed.md` and `{entry}.simplified.md` if they exist in the same directory
   - **Clean up bidirectional links** (see below)
   - Remove entry from `{KB_ROOT}/INDEX.md`
   - Remove entry from `{KB_ROOT}/search-index.json`:
     - Read the JSON, filter out the entry by `id` from the `entries` array
     - Also remove this `id` from any other entry's `related` array
     - Update `last_updated` to current date
     - Write back
   - Update profile.md if needed (remove from 待学习 if present)
5. Output:
   > 已删除「{entry name}」

## Bidirectional Link Cleanup

Before deleting the entry file, read its frontmatter `links` array. For each linked entry ID:
1. Read the linked entry's `.md` file (use path from search-index.json)
2. Remove the deleted entry's ID from the linked entry's frontmatter `links` array
3. Write the linked entry file back

This ensures no dangling links remain in the knowledge base.

## If Not Found

> 未找到「{query}」相关条目。使用 `/kb-list` 查看所有条目。

## Batch Delete

If user provides multiple names separated by comma or space:
- List all matches
- Confirm once for all
- Delete all confirmed entries (with full link cleanup for each)
