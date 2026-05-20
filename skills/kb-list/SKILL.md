---
name: kb-list
description: Use when the user wants to view their knowledge base catalog, see what knowledge entries have been collected, or check the current state of their learning database.
argument-hint: [category]
---

# Knowledge Base - List

## Overview

Display the knowledge base index. Shows categories and entry titles without loading full content.

## Workflow

1. Read `~/.claude/knowledge/INDEX.md`
2. Display the categorized list to user
3. If `$ARGUMENTS` specifies a category, read only that category's `_catalog.md`

## Display Format

### No arguments — show full index

```
=== 知识库目录 ===

📂 技（实践技能）
├── python (3 条)
│   ├── decorators
│   ├── asyncio
│   └── context-managers
├── web (2 条)
│   ├── cors
│   └── jwt-auth
└── devops (1 条)
    └── docker-compose

📂 道（原理理论）
├── design-patterns (2 条)
│   ├── observer-pattern
│   └── strategy-pattern
└── distributed-systems (1 条)
    └── cap-theorem

总计: 9 条  |  技: 6  |  道: 3
状态: new: 5  reviewed: 4
```

### With category argument — show catalog detail

`/kb-list python` → Read `~/.claude/knowledge/技/python/_catalog.md` and display entries with their one-line descriptions.

## If Knowledge Base is Empty

Output:
> 知识库为空。在 coding 过程中我会自动收集知识点，你也可以用 `/learn <topic>` 手动添加。

## Available Actions After Listing

Remind the user of available commands:
- `/kb-detail <entry>` — 查看具体条目
- `/kb-delete <entry>` — 删除条目
- `/kb-simplify <entry>` — 精简讲解
- `/kb-deep <entry>` — 深入讲解
- `/kb-assess` — 刷新知识画像
