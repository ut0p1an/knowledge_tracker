# Knowledge Tracker for Claude Code

[English](README_EN.md)

一个用于 Claude Code 的知识缺口追踪系统。在 vibe coding 过程中自动识别和收集你不熟悉的知识点，建立个人知识库，支持分类管理、知识关联和按需学习。

## Features

- **自动收集**：开启后，Claude 在 coding 过程中主动识别你的知识盲区并记录（需在 CLAUDE.md 中配置启用）
- **手动标记**：使用 `/learn <topic>` 随时标记感兴趣的知识点
- **知识关联**：条目之间支持双向链接，构建知识网络（创建时自动建议 + `/kb 关联` 手动关联）
- **分类管理**：按领域（category）分组管理，技/道作为条目属性标记
- **互动式学习**: 新增 `/kb 测验` 命令，可以根据知识点内容生成测验题，通过主动回忆来巩固学习效果。
- **统一存储**: 每个知识点对应一个 Markdown 文件，文件顶部是精简总结，下方是可无限追加的深入讲解区。
- **渐进式学习**: 使用 `/kb 深入` 命令可多次对同一知识点进行深入探究，每次都会在文件末尾追加新的内容，实现知识的逐步深化。
- **结构化索引**：自动维护 `search-index.json`，支持标签搜索和快速检索。
- **索引修复**：使用 `/kb 修复` 从文件系统重建索引，解决不一致问题。
- **知识画像**：通过自评+客观题问卷建立和维护你的知识能力模型。
- **全局生效**：跨项目共享，知识库持续积累。

## Skills 列表

| 命令 | 功能 |
| --- | --- |
| `/learn <topic>` | 手动标记一个知识点 |
| `/kb` | 知识库统一入口。自然语言描述意图即可： |
| | — `/kb` 浏览目录 / `/kb <条目>` 查看详情 |
| | — `/kb 深入 <条目> [方向]` 追加深入讲解 |
| | — `/kb 测验 [条目]` 间隔重复测验 / `/kb 测验 统计` 查看复习统计 |
| | — `/kb 关联 <A> <B>` 建立双向链接 |
| | — `/kb 删除 <条目>` 删除条目 |
| | — `/kb 评估` 知识画像问卷 / `/kb 修复` 重建索引 |

另外，`knowledge-collector`（需配置启用）和 `knowledge-profile` 会在 coding 过程中由 Claude 自动触发，无需手动调用。

## 安装

### Linux / macOS

```bash
git clone https://github.com/ut0p1an/knowledge_tracker.git
cd knowledge-tracker-plugin
chmod +x install.sh
./install.sh
```

### Windows (Git Bash / MSYS2)

```bash
git clone https://github.com/ut0p1an/knowledge_tracker.git
cd knowledge-tracker-plugin
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/ut0p1an/knowledge_tracker.git
cd knowledge-tracker-plugin
.\install.ps1
```

### 手动安装

如果脚本不适用，手动复制即可：

```bash
# 复制 skills
cp -r skills/* ~/.claude/skills/

# 创建知识库目录并复制模板
mkdir -p ~/.claude/knowledge
cp knowledge-template/INDEX.md ~/.claude/knowledge/
cp knowledge-template/profile.md ~/.claude/knowledge/
cp knowledge-template/assess-history.json ~/.claude/knowledge/
cp knowledge-template/search-index.json ~/.claude/knowledge/
```

安装后**重启 Claude Code** 使 skills 生效。

## 使用指南

### 1. 初始化知识画像

首次安装后，运行自评问卷：

```
/kb 评估
```

Claude 会询问你的角色、经验、并对各领域给出评估问卷，建立你的知识画像。

### 2. 日常使用

正常进行 vibe coding 即可。如果你启用了自动收集（见下方配置段），Claude 会在后台：
- 根据你的提问和代码风格判断知识盲区
- 高确信时自动记录并给出一行提示

你也可以随时手动标记：

```
/learn FastAPI依赖注入
/learn CAP定理
```

创建条目时，系统会自动扫描已有条目并建议可能的关联。

### 3. 查看和管理知识库

```
/kb                         # 浏览目录 + 操作引导
/kb python                  # 查看 python 分类
/kb 元编程                   # 按标签筛选
/kb asyncio                 # 查看条目详情
/kb 深入 asyncio             # 追加深入讲解
/kb 深入 asyncio 和多线程配合 # 深入讲解指定方向
/kb 测验                     # 自动选到期条目复习
/kb 测验 asyncio             # 对指定条目复习
/kb 关联 decorators metaprogramming  # 建立关联
/kb 删除 asyncio             # 删除（需二次确认）
/kb 评估                     # 刷新知识画像
/kb 修复                     # 重建索引
```

### 4. 管理知识关联

自然语言描述即可建立关联：

```
/kb 关联 decorators metaprogramming    # 建立双向链接
```

系统会读取两个条目内容判断关联性：
- 明显相关 → 直接建立双向链接
- 关联可疑 → 提示并让你确认

### 5. 刷新知识画像

随着学习进展，定期刷新画像：

```
/kb 评估
```

系统会避免重复已经问过的问题，只生成新的评估题目。

## 知识条目格式

### "技"类条目（实践技能）

```markdown
---
type: 技
category: python
created: 2026-05-19
level: brief
status: new | reviewed
links: [metaprogramming, closures]
---
# Topic Name

## 是什么（一句话）
## 使用场景
## 基本用法
## 常见陷阱
```

`/kb 深入` 生成的深入讲解直接追加到原始条目文件末尾，支持多次执行持续深化，不产生独立文件。

### "道"类条目（原理理论）

```markdown
---
type: 道
category: distributed-systems
created: 2026-05-19
level: brief
status: new | reviewed
links: [cap-theorem]
---
# Topic Name

## 概念说明
## 相关领域
## 前置知识
## 深入方向
```

## 配置

### 启用自动收集（可选）

在项目或全局 CLAUDE.md 中添加以下配置，开启自动知识收集：

```markdown
# Knowledge Tracker Settings
knowledge-collector: true
```

不配置则只能通过 `/learn` 手动收集。

### 行为变量

在 `skills/knowledge-collector/SKILL.md` 中可以调整：

```yaml
AUTO_NOTIFY_ONLY: true       # true = 高确信时只通知不询问
BACKGROUND_EXPLAIN: true     # true = 后台生成详细内容
```

## 文件结构

```
~/.claude/
├── skills/                          # Skills 目录
│   ├── kb/SKILL.md                   # /kb 统一路由器（浏览/查看/深入/测验/关联/删除/评估/修复）
│   ├── learn/SKILL.md                # /learn 手动标记知识点
│   ├── knowledge-collector/SKILL.md  # 自动检测知识盲区（opt-in，需配置）
│   └── knowledge-profile/SKILL.md
│
└── knowledge/                       # 知识库数据
    ├── INDEX.md                     # 总目录（Markdown 格式，人类可读）
    ├── search-index.json            # 结构化索引（机器检索用）
    ├── profile.md                   # 知识画像
    ├── assess-history.json          # 问卷历史（避免重复）
    └── {category}/                  # 按领域组织的条目
        └── {topic}.md               # 条目文件（简明总结 + 多次深入讲解追加）
```

### search-index.json 结构

每次增删条目时自动维护的结构化索引，用于快速检索、标签筛选和画像联动：

```json
{
  "version": 1,
  "last_updated": "2026-05-20",
  "entries": [
    {
      "id": "decorators",
      "type": "技",
      "category": "python",
      "title": "Python 装饰器",
      "tags": ["python", "函数", "元编程"],
      "related": ["metaprogramming", "context-managers"],
      "profile_domains": ["python"],
      "level": "brief",
      "has_detailed": false,
      "has_simplified": false,
      "status": "new",
      "path": "python/decorators.md",
      "created": "2026-05-20",
      "summary": "用 @语法 包装函数，添加额外行为"
    }
  ]
}
```

字段说明：
| 字段 | 说明 |
| --- | --- |
| `id` | 条目标识（文件名去 .md） |
| `type` | "技" 或 "道"（来自 frontmatter） |
| `category` | 领域目录名 |
| `tags` | 关键词标签，用于搜索和筛选 |
| `related` | 关联条目 ID 列表（双向链接，与 frontmatter `links` 同步） |
| `profile_domains` | 对应知识画像中的领域 |
| `level` | 原始条目详细程度：brief（默认） |
| `has_detailed` | 是否有深入讲解内容（文件中含 `## 深入探讨` 段落） |
| `has_simplified` | 保留字段（历史兼容） |
| `status` | new（新增）或 reviewed（已复习） |
| `path` | 相对于 knowledge/ 的文件路径 |
| `summary` | 一句话摘要 |

## 卸载

```bash
# 删除 skills
rm -rf ~/.claude/skills/knowledge-collector
rm -rf ~/.claude/skills/learn
rm -rf ~/.claude/skills/kb-list
rm -rf ~/.claude/skills/kb-detail
rm -rf ~/.claude/skills/kb-delete
rm -rf ~/.claude/skills/kb-simplify
rm -rf ~/.claude/skills/kb-deep
rm -rf ~/.claude/skills/kb-link
rm -rf ~/.claude/skills/kb-assess
rm -rf ~/.claude/skills/kb-rebuild-index
rm -rf ~/.claude/skills/knowledge-profile

# 删除知识库数据（谨慎！会清除所有已收集的知识）
rm -rf ~/.claude/knowledge
```

## 兼容性

- Claude Code CLI
- 需要 Claude Code 支持 `~/.claude/skills/` 自定义 skill 加载

## Contributing

欢迎提 Issue 和 PR：
- 新增知识条目模板
- 改进自动检测逻辑
- 添加新的管理命令
- 国际化支持

## License

MIT
