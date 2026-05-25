---
name: kb-list
description: Use when the user wants to view their knowledge base catalog, see what knowledge entries have been collected, or check the current state of their learning database.
argument-hint: [category] [--tag <tag>]
---

# Knowledge Base - List

## Overview

Display the knowledge base index. Shows entries grouped by category with type tags, summaries, and links.

## Path Resolution

The knowledge base root (`KB_ROOT`) is:
- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

## Workflow

1. Try to read `{KB_ROOT}/search-index.json`
   - If it exists and has entries: use the index as data source
   - If it doesn't exist or is empty: fall back to reading `{KB_ROOT}/INDEX.md`
2. Parse `$ARGUMENTS` for optional filters
3. Display the categorized list to user

## Argument Parsing

- No arguments → show full index
- `<category>` (e.g., `python`) → filter by category
- `--tag <tag>` (e.g., `--tag 元编程`) → filter by tag from search-index.json

## Display Format

### No arguments — show full index

When using search-index.json, group entries by `category` (sorted alphabetically). Each entry shows its **ID**, **type tag** [技/道], **summary**, and **links**:

```
=== 知识库目录 ===

## distributed-systems (2 条)
• cap-theorem [道] — 分布式系统一致性/可用性/分区容忍三选二  (→ consistency-models)
• consistency-models [道] — 分布式一致性模型对比  (→ cap-theorem)

## python (3 条)
• asyncio [技] — Python 异步编程核心库
• context-managers [技] — with 语句资源管理  (→ decorators)
• decorators [技] — 用 @语法 包装函数  (→ metaprogramming, context-managers)

## web (2 条)
• cors [技] — 跨域资源共享机制
• jwt-auth [技] — JSON Web Token 认证

总计: 7 条  |  技: 5  |  道: 2
状态: new: 4  reviewed: 3
```

Entry format: `• {id} [{type}] — {summary}  (→ {linked-ids})` where links are only shown if `related` is non-empty.

Note: the summary comes from the index's `summary` field. If falling back to INDEX.md, omit summaries and links.

### With category argument — show category detail

`/kb-list python` → Filter index entries where `category == "python"`, display with tags and summaries.

```
## python (3 条)
• asyncio [技] [python, 异步, 并发] — Python 异步编程核心库
• context-managers [技] [python, 资源管理] — with 语句资源管理  (→ decorators)
• decorators [技] [python, 函数, 元编程] — 用 @语法 包装函数  (→ metaprogramming, context-managers)
```

### With --tag argument — filter by tag

`/kb-list --tag 元编程` → Filter index entries where `tags` array contains "元编程".

```
=== 标签「元编程」相关条目 ===
• decorators [技/python] — 用 @语法 包装函数  (→ metaprogramming, context-managers)
• metaclass [道/python] — 元类编程原理  (→ decorators)
```

## If Knowledge Base is Empty

Output:
> 知识库为空。在 coding 过程中我会自动收集知识点，你也可以用 `/learn <topic>` 手动添加。

## Available Actions After Listing

Remind the user of available commands:
- `/kb-detail <id>` — 查看具体条目
- `/kb-delete <id>` — 删除条目
- `/kb-simplify <id> [方向]` — 精简讲解（可指定方向）
- `/kb-deep <id> [方向]` — 深入讲解（可指定方向）
- `/kb-link <id-A> <id-B>` — 关联两个条目
- `/kb-list --tag <tag>` — 按标签筛选
- `/kb-assess` — 刷新知识画像
