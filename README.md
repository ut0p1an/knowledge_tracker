# Knowledge Tracker for Claude Code

[English](README_EN.md)

一个用于 Claude Code 的知识缺口追踪系统。在 vibe coding 过程中自动识别和收集你不熟悉的知识点，建立个人知识库，支持分类管理和按需学习。

## Features

- **自动收集**：开启后，Claude 在 coding 过程中主动识别你的知识盲区并记录（需在 CLAUDE.md 中配置启用）
- **手动标记**：使用 `/learn <topic>` 随时标记感兴趣的知识点
- **分类管理**：知识分为"技"（实践技能）和"道"（原理理论）两类
- **按需学习**：支持精简版和深入版讲解，原始条目不受影响，可指定方向
- **结构化索引**：自动维护 search-index.json，支持标签搜索和快速检索
- **索引修复**：使用 `/kb-rebuild-index` 从文件系统重建索引，解决不一致问题
- **知识画像**：通过自评+客观题问卷建立和维护你的知识能力模型
- **全局生效**：跨项目共享，知识库持续积累

## Skills 列表

| 命令 | 功能 |
| --- | --- |
| `/learn <topic>` | 手动标记一个知识点 |
| `/kb-list [category] [--tag <tag>]` | 查看知识库目录（支持标签筛选） |
| `/kb-detail <entry>` | 查看具体条目内容 |
| `/kb-delete <entry>` | 删除条目 |
| `/kb-simplify <entry> [方向]` | 精简版讲解（可指定方向） |
| `/kb-deep <entry> [方向]` | 深入版讲解（可指定方向） |
| `/kb-assess` | 自评问卷（初始化/刷新知识画像，支持分批测试） |
| `/kb-rebuild-index` | 从文件系统重建索引（修复不一致） |

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
mkdir -p ~/.claude/knowledge/技 ~/.claude/knowledge/道
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
/kb-assess
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

### 3. 查看和管理知识库

```
/kb-list              # 查看总目录（带摘要）
/kb-list python       # 查看 python 分类（带标签和摘要）
/kb-list --tag 元编程  # 按标签筛选条目
/kb-detail asyncio    # 查看具体条目
/kb-simplify asyncio  # 精简版
/kb-simplify asyncio 只看语法          # 精简版，聚焦语法
/kb-deep asyncio      # 深入版
/kb-deep asyncio 和多线程的配合使用    # 深入版，聚焦多线程方向
/kb-delete asyncio    # 删除
```

### 4. 刷新知识画像

随着学习进展，定期刷新画像：

```
/kb-assess
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
---
# Topic Name

## 是什么（一句话）
## 使用场景
## 基本用法
## 常见陷阱
```

深入版（`/kb-deep` 生成）和精简版（`/kb-simplify` 生成）保存为独立文件，不覆盖原始条目。

### "道"类条目（原理理论）

```markdown
---
type: 道
category: distributed-systems
created: 2026-05-19
level: brief
status: new | reviewed
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
│   ├── knowledge-collector/SKILL.md  # 自动检测知识盲区（opt-in，需配置）
│   ├── learn/SKILL.md                # /learn 手动标记知识点
│   ├── kb-list/SKILL.md
│   ├── kb-detail/SKILL.md
│   ├── kb-delete/SKILL.md
│   ├── kb-simplify/SKILL.md
│   ├── kb-deep/SKILL.md
│   ├── kb-assess/SKILL.md
│   ├── kb-rebuild-index/SKILL.md     # /kb-rebuild-index 重建索引
│   └── knowledge-profile/SKILL.md
│
└── knowledge/                       # 知识库数据
    ├── INDEX.md                     # 总目录（Markdown 格式，人类可读）
    ├── search-index.json            # 结构化索引（机器检索用）
    ├── profile.md                   # 知识画像
    ├── assess-history.json          # 问卷历史（避免重复）
    ├── 技/                          # 实践技能
    │   └── {category}/
    │       ├── {topic}.md            # 原始条目（brief）
    │       ├── {topic}.detailed.md   # 深入版（/kb-deep 生成）
    │       └── {topic}.simplified.md # 精简版（/kb-simplify 生成）
    └── 道/                          # 原理理论
        └── {category}/
            ├── {topic}.md
            ├── {topic}.detailed.md
            └── {topic}.simplified.md
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
      "related": ["context-managers"],
      "profile_domains": ["python"],
      "level": "brief",
      "status": "new",
      "path": "技/python/decorators.md",
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
| `type` | "技" 或 "道" |
| `category` | 子分类目录名 |
| `tags` | 关键词标签，用于搜索和筛选 |
| `related` | 关联条目 ID 列表 |
| `profile_domains` | 对应知识画像中的领域 |
| `level` | 原始条目详细程度：brief（默认） |
| `has_detailed` | 是否有 .detailed.md 文件 |
| `has_simplified` | 是否有 .simplified.md 文件 |
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
