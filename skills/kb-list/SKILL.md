---
name: kb-list
description: Use when the user wants to view their knowledge base catalog, see what knowledge entries have been collected, or check the current state of their learning database.
argument-hint: [category] [--tag <tag>]
---

# Knowledge Base - List

## Overview

Display the knowledge base index. Shows categories and entry titles without loading full content.

## Workflow

1. Try to read `~/.claude/knowledge/search-index.json`
   - If it exists and has entries: use the index as data source
   - If it doesn't exist or is empty: fall back to reading `~/.claude/knowledge/INDEX.md`
2. Parse `$ARGUMENTS` for optional filters
3. Display the categorized list to user

## Argument Parsing

- No arguments → show full index
- `<category>` (e.g., `python`) → filter by category
- `--tag <tag>` (e.g., `--tag 元编程`) → filter by tag from search-index.json

## Display Format

### No arguments — show full index

When using search-index.json, group entries by `type` then `category`:

```
=== 知识库目录 ===

📂 技（实践技能）
├── python (3 条)
│   ├── decorators — 用 @语法 包装函数，添加额外行为
│   ├── asyncio — Python 异步编程核心库
│   └── context-managers — with 语句资源管理
├── web (2 条)
│   ├── cors — 跨域资源共享机制
│   └── jwt-auth — JSON Web Token 认证
└── devops (1 条)
    └── docker-compose — 多容器编排工具

📂 道（原理理论）
├── design-patterns (2 条)
│   ├── observer-pattern — 观察者模式，事件驱动解耦
│   └── strategy-pattern — 策略模式，运行时切换算法
└── distributed-systems (1 条)
    └── cap-theorem — 分布式系统一致性/可用性/分区容忍三选二

总计: 9 条  |  技: 6  |  道: 3
状态: new: 5  reviewed: 4
```

Note: the summary after "—" comes from the index's `summary` field. If falling back to INDEX.md, omit summaries.

### With category argument — show catalog detail

`/kb-list python` → Filter index entries where `category == "python"`, display with summaries and tags.

```
📂 python (3 条)
├── decorators [python, 函数, 元编程] — 用 @语法 包装函数
├── asyncio [python, 异步, 并发] — Python 异步编程核心库
└── context-managers [python, 资源管理] — with 语句资源管理
```

### With --tag argument — filter by tag

`/kb-list --tag 元编程` → Filter index entries where `tags` array contains "元编程".

```
=== 标签「元编程」相关条目 ===
├── [技/python] decorators — 用 @语法 包装函数
└── [道/design-patterns] metaclass — 元类编程原理
```

## If Knowledge Base is Empty

Output:
> 知识库为空。在 coding 过程中我会自动收集知识点，你也可以用 `/learn <topic>` 手动添加。

## Available Actions After Listing

Remind the user of available commands:
- `/kb-detail <entry>` — 查看具体条目
- `/kb-delete <entry>` — 删除条目
- `/kb-simplify <entry> [方向]` — 精简讲解（可指定方向）
- `/kb-deep <entry> [方向]` — 深入讲解（可指定方向）
- `/kb-list --tag <tag>` — 按标签筛选
- `/kb-assess` — 刷新知识画像
