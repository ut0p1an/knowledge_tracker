---
name: kb
description: |
  知识库统一入口。用自然语言描述意图即可路由到对应操作。
  支持：浏览目录、查看详情、深入讲解、测验复习、关联条目、删除条目、知识评估、修复索引。
argument-hint: "[操作描述] — 例如：/kb、/kb asyncio、/kb 深入 decorators、/kb 测验、/kb 关联 A B、/kb 删除 xxx、/kb 评估、/kb 修复"
---

# Knowledge Base Router

统一知识库入口。根据用户自然语言输入解析意图，路由到对应操作。

## 路由规则

### 步骤 1：解析 $ARGUMENTS

读取 `$ARGUMENTS`。如果为空 → 跳转到 **[操作] 展示目录**。

### 步骤 2：匹配操作意图

按以下优先级检查 `$ARGUMENTS` 中的关键词。**匹配到第一条即停止。**

| 优先级 | 操作 | 触发关键词 |
|---|---|---|
| 1 | 删除 | 删除、移除、去掉、删掉 |
| 2 | 关联 | 关联、链接、connect、link |
| 3 | 深入 | 深入、讲解、讲讲、了解更多、deep dive、展开 |
| 4 | 测验 | 测验、测试、quiz、复习、review、考试 |
| 4b | 测验统计 | 统计、stats |
| 5 | 评估 | 评估、画像、assess、自评 |
| 6 | 修复 | 修复、重建、rebuild、fix、同步索引 |
| 7 | 查看 | 默认（以上都不匹配） |

**测验 + 统计同时出现**：仅展示复习统计，不做测验。

**1 个操作关键词 + "统计"**：操作优先。"测验 统计" = 跳过测验仅展示统计。

### 步骤 3：提取实体

从 `$ARGUMENTS` 中提取实体名：

1. 去除已识别的操作关键词
2. 去除停用词：的、一下、帮我、这个、那个、把、和、与、跟、以及、or、and
3. 以空格、逗号、"和"、"与"、"跟"、"以及" 为分隔符分割为实体片段
4. 去除空白片段

保留未匹配到的文本片段作为"方向描述"（用于深入讲解的方向参数）。

### 步骤 4：解析实体 → 匹配 search-index.json

对每个实体片段，按以下顺位在 `{KB_ROOT}/search-index.json` 中匹配：

1. `entry.id` 精确匹配 → 命中条目
2. `entry.title` 包含匹配 → 命中条目（多个则展示候选项让用户选）
3. `category` 目录名匹配 → 命中分类 → 筛选目录
4. `entry.tags` 包含匹配 → 命中标签 → 筛选目录
5. 无匹配 → 保留为自由文本

**冲突裁决**：
- 同时命中 entry 和 category → 优先 entry（更具体），末尾附加提示"📂 或查看分类「{category}」？"
- 多个候选项 → 展示列表，让用户通过 `AskUserQuestion` 选择
- 提取到 2 个实体、无操作词 → 推断为 **关联（link）** 意图

### 步骤 5：分发

根据步骤 2 确定的操作意图和步骤 4 提取的实体，跳转到下方对应的 `[操作]` section。

---

## [操作] 展示目录

**触发**：空输入、匹配到 category、匹配到 tag、默认兜底。

### KB_ROOT 路径

- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

### 工作流

1. 读取 `{KB_ROOT}/search-index.json`
2. 如果索引为空或不存在 → 输出：
   ```
   知识库为空。在 coding 过程中我会自动收集知识点，你也可以用 /learn <topic> 手动添加。
   ```
3. 如果有 category/tag 筛选 → 过滤 entries
4. 按 category 分组展示。每个条目格式：
   ```
   • {id} [{type}] — {summary}  (→ {related-ids})
   ```
   `(→ ...)` 仅在 `related` 非空时展示。
5. 底部统计行：
   ```
   总计: {total} 条  |  技: {n1}  |  道: {n2}
   ```
6. 计算到期复习条目（`due_date` <= 今天），如有则追加：
   ```
   待复习: {n3} 条
   ```
7. 操作引导栏：
   ```
   ——
   💡 试试：
     /kb <条目名>        — 查看详情
     /kb 深入 <条目>     — 追加深入讲解
     /kb 测验            — 开始知识复习
     /kb 评估            — 刷新知识画像
   ```

### 按 category 筛选

`/kb python` → category == "python" 的条目，格式附加 tags：
```
• asyncio [技] [python, 异步, 并发] — Python 异步编程核心库
```

### 按 tag 筛选

`/kb 元编程` 但"元编程"匹配到 tag → 过滤 entries where tags 包含 "元编程"：
```
=== 标签「元编程」相关条目 ===
• decorators [技/python] — 用 @语法 包装函数  (→ metaprogramming)
```

---

## [操作] 查看详情

**触发**：匹配到唯一条目，且无其他操作关键词。

### 工作流

1. 用 `path` 字段读取 `{KB_ROOT}/{path}` 的内容
2. 读取 `search-index.json` 获取该条目的 `related` 数组
3. 展示条目全文（含所有追加的深入讲解段落）
4. 展示关联条目区：
   ```
   🔗 关联条目:
   • {linked-id} [{type}/{category}] — {summary}
   ```
   （从 search-index.json 读取关联条目的 type/category/summary）
5. 操作栏（用实际条目名替换 `{entry}`）：
   ```
   ——
   📌 你可以：
     /kb 深入 {entry}          — 追加深入讲解
     /kb 测验 {entry}           — 复习此知识点
     /kb 关联 {entry} <其他>    — 关联另一个条目
     /kb 删除 {entry}           — 删除此条目
   ```

### 找不到条目

```
未找到「{query}」相关条目。

你可以：
  /kb              — 浏览现有知识库
  /learn {query}   — 将此主题加入知识库
```

---

## [操作] 深入讲解

**触发**：含"深入/讲解/讲讲/了解更多/deep dive/展开"关键词。

### 参数提取

- 目标条目：第一个匹配到的实体
- 方向描述：操作关键词之后的剩余文本（去除条目名后的其他内容）

### 工作流

1. 在 `search-index.json` 中查找条目
2. 如果找不到 → 提示用户并引导 `/kb` 或 `/learn`
3. 读取条目文件 `{KB_ROOT}/{path}`
4. 生成深入讲解内容。新段落标题格式：`## 深入探讨 ({{current_date}}){方向后缀}`，如方向描述非空则追加 ` - {方向描述}`
5. **追加**到条目文件末尾（Read 原有内容 + 追加新内容 → Write 写回）
6. 首次深入讲解时，将 search-index.json 中该条目的 `has_detailed` 设为 `true`，更新 `last_updated`
7. 向用户输出新增的深入讲解内容
8. 底部确认：
   ```
   ✅ 深入讲解已追加到「{entry}」

   ——
   📌 你可以：
     /kb {entry}               — 查看完整内容
     /kb 测验 {entry}           — 测试掌握程度
     /kb 深入 {entry} <新方向>  — 换个角度继续深化
   ```

### 关键约束

- **追加式**：新内容追加到文件末尾，不覆盖已有内容
- **可累积**：多次执行追加多个 `## 深入探讨` 段落
- **search-index 更新**：首次深入讲解时将 `has_detailed` 设为 `true`

---

## [操作] 测验复习

**触发**：含"测验/测试/quiz/复习/review/考试"关键词。

### 仅统计模式

含 "统计/stats" → 仅展示统计：

1. 读取 `search-index.json`
2. 遍历所有条目，统计 `due_date` <= 今天的（到期）和 > 今天的（待复习）
3. 输出：
   ```
   📊 复习统计：
   - {due_count} 个条目已到期
   - {upcoming_count} 个条目待复习
   - 共 {total_count} 个条目
   ```

### 测验模式

1. **选择目标条目**：
   - 如果指定了条目名 → 在 search-index.json 中查找
   - 如果未指定 → 自动选择 `due_date` 最早（最久未复习）的到期条目
   - 如无到期条目 → 输出 "🎉 太棒了！所有知识点都已复习完毕。" + 统计
2. **读取条目内容**：`{KB_ROOT}/{path}`
3. **生成问题**：基于条目内容生成 1 道开放式问答题（"what is" 或 "how to" 类型，非选择题/判断题）
4. **展示问题**：用 `AskUserQuestion` 展示，等待用户回答
5. **评估回答**：由 Claude 评估质量并打分 0-5（SM-2 标准）：
   - 5 = 完美
   - 4 = 正确但略有犹豫
   - 3 = 正确但需努力回忆
   - 2 = 错误但见答案后觉得熟悉
   - 1 = 错误且答案陌生
   - 0 = 完全记不得
6. **更新 SM-2 参数**：
   - quality >= 3: repetitions++, interval 按 SM-2 递进（1→6→interval*easiness）
   - quality < 3: repetitions=0, interval=1
   - 更新 easiness = easiness + (0.1 - (5-q)*(0.08 + (5-q)*0.02))，下限 1.3
   - 更新 due_date = 今天 + interval 天
   - 写回 search-index.json
7. **输出反馈**，包含评估反馈、下次复习日期、复习间隔、简易度

---

## [操作] 关联条目

**触发**：含"关联/链接/connect/link"关键词，或自然语言中出现两个已识别的条目名。

### 工作流

1. 提取两个实体名 A 和 B
2. 如果只提取到 1 个实体 → 提示用户补充第二个
3. 如果 A == B → 拒绝："不能将条目与自身关联。"
4. 在 `search-index.json` 中查找两个条目
5. 如果任一不存在 → 提示未找到
6. 检查是否已关联 → 已关联则提示
7. 读取两个条目文件的内容
8. **判断关联性**：
   - 明显相关（同 domain、概念有重叠、一个为另一个的基础/应用）→ 直接建立链接
   - 关联可疑 → `AskUserQuestion` 警告并让用户确认
9. **建立双向链接**：
   - a. 更新条目 A 的 frontmatter `links`，添加 B 的 ID
   - b. 更新条目 B 的 frontmatter `links`，添加 A 的 ID
   - c. 更新 search-index.json：A 的 `related` 加 B，B 的 `related` 加 A，更新 `last_updated`
10. **输出**：已关联 + 关联理由 + 操作栏

---

## [操作] 删除条目

**触发**：含"删除/移除/去掉/删掉"关键词。

### 工作流

1. 提取目标实体名
2. 在 `search-index.json` 中查找
3. 如果找不到 → 提示未找到
4. 展示待删除条目信息（不立即删除）：
   ```
   ⚠️ 即将删除：
     {title} [{type}/{category}] — {summary}
     深入讲解: {N} 次  |  关联条目: {related-ids}

   如需确认删除，请输入：确认删除 {entry-id}
   ```
5. **等待用户输入精确确认语句** `确认删除 {entry-id}`（不区分大小写）
6. 执行删除：删除条目文件 + 清理所有双向链接（更新关联条目的 frontmatter 和 search-index.json）+ 从 search-index.json 移除此条目
7. **输出**：已删除 + 清理了 N 条关联链接

### 安全约束

- **必须**精确输入确认语句
- 确认失败或用户取消 → 输出 "已取消删除操作。"

---

## [操作] 知识评估

**触发**：含"评估/画像/assess/自评"关键词。

### 工作流

执行完整的知识画像评估流程：

1. 检查 `{KB_ROOT}/profile.md` 是否存在
2. **首次评估**：Phase 1（身份信息）+ Phase 2（领域自评 1-5 星）+ Phase 2.5（时间估算 + 跳过/分批选项）+ Phase 3（客观题测验：选择题/判断题/填空题，每批 3-4 道）
3. **刷新评估**：展示当前画像摘要 → 询问变更范围 → 生成新题目（跳过 `assess-history.json` 中已问过的）
4. **分批评估**：检查 `assess-history.json` 的 `pending_domains`，支持继续/重新开始/跳过
5. 评分调整：≥80% 上调，40-79% 维持，<40% 下调
6. 保存 `profile.md` 和 `assess-history.json`

领域分类：语言与框架（Python、JavaScript/TypeScript、Go/Rust/其他）、后端（Web框架、数据库、API设计）、前端（React/Vue、CSS/样式）、DevOps（Docker/K8s、CI/CD、云服务）、计算机科学（算法与数据结构、设计模式、分布式系统、网络协议）

问题类型混杂：每批 3-4 道，含选择题（4 选 1）、判断题（正确/错误）、填空题（2 个提示选项）。错题即时展示解析。所有问题保存到 `assess-history.json` 避免重复。

---

## [操作] 修复索引

**触发**：含"修复/重建/rebuild/fix/同步索引"关键词。

### 工作流

1. 扫描 `{KB_ROOT}/*/` 下所有 `.md` 文件（跳过 INDEX.md、profile.md）
2. 解析每个文件的 frontmatter（type, category, created, level, status, links）和 `# ` 标题
3. 重建 `search-index.json`（以文件系统为 source of truth）：
   - id = 文件名去 .md
   - summary = 第一个非空正文行
   - has_detailed = 文件中是否含 `## 深入探讨` 段落
4. **验证并修复双向链接**：A 的 links 有 B ↔ B 的 links 有 A。断裂链接自动修复（补充反向链接）或报告（目标不存在则移除）
5. 重建 `INDEX.md`
6. **输出修复报告**：扫描文件数、技/道统计、分类列表、关联链接数及修复数

## 公共格式

### 条目展示格式（目录中）

```
• {id} [{type}] — {summary}  (→ {related-1}, {related-2})
```
`(→ ...)` 仅在 `related` 数组非空时展示。

### 操作引导栏格式

操作栏中 `{entry}` 必须替换为当前操作的实际条目 ID。使用中文输出所有用户界面文本。

## 重要约束

- 所有知识库路径使用 KB_ROOT（Linux/macOS = `$HOME/.claude/knowledge`，Windows = `$env:USERPROFILE\.claude\knowledge`）
- 删除必须精确确认
- 关联低置信时询问确认
- 操作栏中的占位符 `{entry}` 必须替换为当前操作的实际条目 ID
- 使用中文输出所有用户界面文本
