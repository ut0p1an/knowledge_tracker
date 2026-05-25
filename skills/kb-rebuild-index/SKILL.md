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

## Path Resolution

The knowledge base root (`KB_ROOT`) is:
- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

## Workflow

1. **Scan directory** — recursively find all `.md` files under `{KB_ROOT}/*/` (all category subdirectories). Skip `INDEX.md`, `profile.md`, and any files in the root `{KB_ROOT}/` that are not in a subdirectory. Also skip `.detailed.md` and `.simplified.md` files (they are variants, not primary entries).

2. **Parse each entry** — read frontmatter (`type`, `category`, `created`, `level`, `status`, `links`, `source-project`) and extract title from the first `# ` heading.

3. **Rebuild search-index.json** — construct fresh entries array from parsed data:
   ```json
   {
     "version": 1,
     "last_updated": "{today YYYY-MM-DD}",
     "entries": [
       {
         "id": "{filename without .md}",
         "type": "{技|道, from frontmatter}",
         "category": "{parent folder name}",
         "title": "{# heading}",
         "tags": [],
         "related": ["{from frontmatter links}"],
         "profile_domains": [],
         "level": "{from frontmatter, default 'brief'}",
         "has_detailed": "{true if .detailed.md exists}",
         "has_simplified": "{true if .simplified.md exists}",
         "status": "{from frontmatter, default 'new'}",
         "path": "{category}/{filename}",
         "created": "{from frontmatter}",
         "summary": "{first non-heading, non-frontmatter line}"
       }
     ]
   }
   ```

4. **Validate bidirectional links** — after building all entries:
   - For each entry A with `links: [B]` in frontmatter, check that entry B also has A in its `links`
   - If B exists but doesn't link back to A: add A to B's frontmatter `links` and to B's `related` in index (auto-fix)
   - If B doesn't exist as an entry: report as broken link, remove from A's `links` frontmatter and `related` in index
   - Report all fixes applied

5. **Rebuild INDEX.md** — generate from the entries array, grouped by category:
   ```markdown
   # 知识库目录

   ## {category} ({N} 条)
   - {id} [{type}] — {summary}
   ...

   ---
   总计: {total} 条  |  技: {n1}  |  道: {n2}
   最后更新: {today}
   ```

6. **Report** — output summary:
   ```
   索引重建完成：
   - 扫描到 {N} 个条目文件
   - 技: {n1} 条 | 道: {n2} 条
   - 分类: {list of categories}
   - 关联链接: {link_count} 个（修复 {fixed_count} 个断裂链接）
   - 已更新 search-index.json 和 INDEX.md
   ```

## Notes

- This skill is the recovery mechanism — it treats files on disk as the source of truth
- Tags and profile_domains cannot be inferred from file content alone — set them to empty arrays (user can enrich later via `/learn` or manual edit)
- **Links** are extracted from frontmatter `links` field — these ARE preserved and validated
- If an existing search-index.json has richer metadata (tags, related, profile_domains) for an entry that still exists on disk, preserve that metadata
- summary is best-effort: first paragraph line after the heading
