# Knowledge Tracker for Claude Code

一个用于 Claude Code 的知识缺口追踪系统。在 vibe coding 过程中自动识别和收集你不熟悉的知识点，建立个人知识库，支持分类管理和按需学习。

## Features

- **自动收集**：Claude 在 coding 过程中主动识别你的知识盲区并记录
- **手动标记**：使用 `/learn <topic>` 随时标记感兴趣的知识点
- **分类管理**：知识分为"技"（实践技能）和"道"（原理理论）两类
- **按需学习**：支持精简版和深入版讲解切换
- **知识画像**：通过自评问卷建立和维护你的知识能力模型
- **全局生效**：跨项目共享，知识库持续积累

## Skills 列表

| 命令 | 功能 |
| --- | --- |
| `/learn <topic>` | 手动标记一个知识点 |
| `/kb-list [category]` | 查看知识库目录 |
| `/kb-detail <entry>` | 查看具体条目内容 |
| `/kb-delete <entry>` | 删除条目 |
| `/kb-simplify <entry>` | 精简版讲解 |
| `/kb-deep <entry>` | 深入版讲解 |
| `/kb-assess` | 自评问卷（初始化/刷新知识画像） |

另外，`knowledge-collector` 和 `knowledge-profile` 会在 coding 过程中由 Claude 自动触发，无需手动调用。

## 安装

### Linux / macOS

```bash
git clone https://github.com/YOUR_USERNAME/knowledge-tracker-plugin.git
cd knowledge-tracker-plugin
chmod +x install.sh
./install.sh
```

### Windows (Git Bash / MSYS2)

```bash
git clone https://github.com/YOUR_USERNAME/knowledge-tracker-plugin.git
cd knowledge-tracker-plugin
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/YOUR_USERNAME/knowledge-tracker-plugin.git
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

正常进行 vibe coding 即可。Claude 会在后台：
- 根据你的提问和代码风格判断知识盲区
- 高确信时自动记录并给出一行提示
- 不确信时询问你是否需要记录

你也可以随时手动标记：

```
/learn FastAPI依赖注入
/learn CAP定理
```

### 3. 查看和管理知识库

```
/kb-list              # 查看总目录
/kb-list python       # 查看 python 分类
/kb-detail asyncio    # 查看具体条目
/kb-simplify asyncio  # 精简版
/kb-deep asyncio      # 深入版
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
level: brief | simplified | detailed
status: new | reviewed
---
# Topic Name

## 是什么（一句话）
## 使用场景
## 基本用法
## 常见陷阱
```

### "道"类条目（原理理论）

```markdown
---
type: 道
category: distributed-systems
created: 2026-05-19
level: brief | simplified | detailed
status: new | reviewed
---
# Topic Name

## 概念说明
## 相关领域
## 前置知识
## 深入方向
```

## 配置

在 `skills/knowledge-collector/SKILL.md` 中可以调整行为变量：

```yaml
AUTO_NOTIFY_ONLY: true       # true = 高确信时只通知不询问
ASK_ON_UNCERTAIN: true       # true = 不确信时询问用户确认
```

## 文件结构

```
~/.claude/
├── skills/                          # Skills 目录
│   ├── knowledge-collector/SKILL.md
│   ├── kb-list/SKILL.md
│   ├── kb-detail/SKILL.md
│   ├── kb-delete/SKILL.md
│   ├── kb-simplify/SKILL.md
│   ├── kb-deep/SKILL.md
│   ├── kb-assess/SKILL.md
│   └── knowledge-profile/SKILL.md
│
└── knowledge/                       # 知识库数据
    ├── INDEX.md                     # 总目录
    ├── profile.md                   # 知识画像
    ├── assess-history.json          # 问卷历史（避免重复）
    ├── 技/                          # 实践技能
    │   └── {category}/
    │       ├── _catalog.md
    │       └── {topic}.md
    └── 道/                          # 原理理论
        └── {category}/
            ├── _catalog.md
            └── {topic}.md
```

## 卸载

```bash
# 删除 skills
rm -rf ~/.claude/skills/knowledge-collector
rm -rf ~/.claude/skills/kb-list
rm -rf ~/.claude/skills/kb-detail
rm -rf ~/.claude/skills/kb-delete
rm -rf ~/.claude/skills/kb-simplify
rm -rf ~/.claude/skills/kb-deep
rm -rf ~/.claude/skills/kb-assess
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
