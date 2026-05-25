---
name: kb-rebuild-index
description: Use when the user wants to rebuild their knowledge base index files from the actual entry files on disk. Fixes inconsistencies between search-index.json, INDEX.md and the actual entries.
---

# Knowledge Base - Rebuild Index

## Overview

Scan all actual entry files in the knowledge base directory and rebuild `search-index.json` and `INDEX.md` from scratch. Use this to fix inconsistencies caused by failed background agents or manual edits.

## When to Use

- User reports missing entries in `/kb-list` that exist as files
- After a background Agent failure leaves partial state
- User explicitly asks to rebuild/fix/sync the knowledge base index
- After manual file edits to the knowledge base directory

## Workflow

1. **Scan directory** — recursively find all `.md` files under `~/.claude/knowledge/技/` and `~/.claude/knowledge/道/` (skip `_catalog.md` files, skip `INDEX.md`, skip `profile.md`)
2. **Parse each entry** — read frontmatter (`type`, `category`, `created`, `level`, `status`, `source-project`) and extract title from the first `# ` heading
3. **Rebuild search-index.json** — construct fresh entries array from parsed data:
   ```json
   {
     "version": 1,
     "last_updated": "{today YYYY-MM-DD}",
     "entries": [
       {
         "id": "{filename without .md}",
         "type": "{技|道}",
         "category": "{parent folder name}",
         "title": "{# heading}",
         "tags": [],
         "related": [],
         "profile_domains": [],
         "level": "{from frontmatter, default 'brief'}",
         "status": "{from frontmatter, default 'new'}",
         "path": "{技|道}/{category}/{filename}",
         "created": "{from frontmatter}",
         "summary": "{first non-heading, non-frontmatter line}"
       }
     ]
   }
   ```
4. **Rebuild INDEX.md** — generate from the entries array, grouped by type then category
5. **Report** — output summary:
   ```
   索引重建完成：
   - 扫描到 {N} 个条目文件
   - 技: {n1} 条 | 道: {n2} 条
   - 分类: {list of categories}
   - 已更新 search-index.json 和 INDEX.md
   ```

## Path Resolution

Use the knowledge base root path. Resolve `~` as:
- Linux/macOS: `$HOME/.claude/knowledge/`
- Windows: `$env:USERPROFILE/.claude/knowledge/`

Check which platform you're on and use the appropriate path.

## Notes

- This skill is the recovery mechanism — it treats files on disk as the source of truth
- Tags, related, and profile_domains cannot be inferred from file content alone — set them to empty arrays (user can enrich later via `/learn` or manual edit)
- If an existing search-index.json has richer metadata (tags, related) for an entry that still exists on disk, preserve that metadata
- summary is best-effort: first paragraph line after the heading
