---
name: kb-quiz
description: |
  根据知识点内容生成一个互动测验，并基于你的回答质量使用间隔重复算法（SM-2）安排下一次复习。
  - `kb-quiz`: 自动选择一个到期的知识点进行复习。
  - `kb-quiz <entry>`: 对指定的知识点进行测验。
  - `kb-quiz --stats`: 显示当前的复习统计信息。
arguments:
  - name: entry
    description: "要进行测验的知识点 ID。如果留空，将自动选择一个到期的知识点。"
    type: string
    optional: true
  - name: stats
    description: "如果为 true，则显示复习统计信息。"
    type: boolean
    optional: true
steps:
  - tool: user_input
    id: entry_id
    prompt: "请输入要测验的知识点 ID，或留空以自动选择到期条目，或输入 '--stats' 查看统计："
    default: "{{entry}}"
  
  - tool: file_read
    id: read_index
    path: ~/.claude/knowledge/search-index.json

  - tool: code
    id: process_quiz_logic
    source: |
      const fs = require('fs');
      const path = require('path');
      const index = JSON.parse(tools.read_index.content);
      const entryId = tools.entry_id.text.trim();
      const KNOWLEDGE_BASE_PATH = path.join(process.env.HOME, '.claude', 'knowledge');

      function getDueDateStats(entries) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        let dueCount = 0;
        let upcomingCount = 0;
        let totalCount = entries.length;

        entries.forEach(e => {
          if (e.due_date) {
            const dueDate = new Date(e.due_date);
            if (dueDate <= today) {
              dueCount++;
            } else {
              upcomingCount++;
            }
          }
        });
        return { dueCount, upcomingCount, totalCount };
      }

      if (entryId === '--stats') {
        const stats = getDueDateStats(index.entries);
        return `📊 复习统计：\n- **${stats.dueCount}** 个条目已到期\n- **${stats.upcomingCount}** 个条目待复习\n- 共 **${stats.totalCount}** 个条目`;
      }

      let entry;
      if (!entryId) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const dueEntries = index.entries.filter(e => e.due_date && new Date(e.due_date) <= today);
        if (dueEntries.length === 0) {
          const stats = getDueDateStats(index.entries);
          return `🎉 太棒了！所有知识点都已复习完毕。\n\n📊 当前统计：\n- **${stats.dueCount}** 个条目已到期\n- **${stats.upcomingCount}** 个条目待复习\n- 共 **${stats.totalCount}** 个条目`;
        }
        // 优先选择最久没复习的
        dueEntries.sort((a, b) => new Date(a.due_date) - new Date(b.due_date));
        entry = dueEntries[0];
        tools.user_output.print(`发现到期条目，自动选择：**${entry.id}**`);
      } else {
        entry = index.entries.find(e => e.id === entryId);
      }

      if (!entry) {
        return `❌ 错误：找不到知识点 "${entryId}"。`;
      }
      
      // 将选中的条目信息传递给下一步
      return { entry };

  - tool: user_output
    id: show_entry_or_error
    content: "{{process_quiz_logic.result}}"
    skip_if: "{{process_quiz_logic.result.entry}}"

  - tool: stop
    if: "{{!process_quiz_logic.result.entry}}"

  - tool: file_read
    id: read_entry_file
    path: "~/.claude/knowledge/{{process_quiz_logic.result.entry.file_path}}"

  - tool: llm_prompt
    id: generate_quiz
    template: |
      Based on the following knowledge entry content, please generate a single, concise question to test the user's understanding of the core concept. The question should be a "what is" or "how to" style question. Avoid multiple-choice or true/false questions.

      ---
      **Knowledge Entry: {{process_quiz_logic.result.entry.title}}**

      {{read_entry_file.content}}
      ---

      Question:
    
  - tool: user_input
    id: user_answer
    prompt: |
      **知识点: {{process_quiz_logic.result.entry.title}}**
      
      🤔 **问题:** {{generate_quiz.text}}
      
      请输入你的回答:

  - tool: llm_prompt
    id: evaluate_answer
    template: |
      The user was asked a question about a knowledge entry. Evaluate their answer and provide a concise feedback.
      Then, on a new line, provide a quality score from 0 to 5 based on the SM-2 algorithm's criteria:
      5 - Perfect response.
      4 - Correct response, but with minor hesitation.
      3 - Correct response, but required some effort to recall.
      2 - Incorrect response, but upon seeing the solution, it seemed familiar.
      1 - Incorrect response, and the solution seemed new.
      0 - Complete blackout, no recollection.

      ---
      **Knowledge Entry Summary:**
      {{process_quiz_logic.result.entry.summary}}

      **Question:**
      {{generate_quiz.text}}

      **User's Answer:**
      {{user_answer.text}}
      ---

      Feedback and Score (e.g., "Your answer is correct... 
4"): 

  - tool: code
    id: parse_evaluation
    source: |
      const result = tools.evaluate_answer.text;
      const lines = result.split('\n');
      const feedback = lines.slice(0, -1).join('\n').trim();
      const quality = parseInt(lines[lines.length - 1], 10);
      
      if (isNaN(quality) || quality < 0 || quality > 5) {
        tools.user_output.print(`⚠️ 评估分数解析失败，将使用默认值 3。\n${result}`);
        return { feedback: result, quality: 3 };
      }
      
      return { feedback, quality };

  - tool: code
    id: update_srs
    source: |
      const fs = require('fs');
      const path = require('path');
      const index = JSON.parse(tools.read_index.content);
      const entryId = tools.process_quiz_logic.result.entry.id;
      const quality = tools.parse_evaluation.result.quality;

      const entryIndex = index.entries.findIndex(e => e.id === entryId);
      if (entryIndex === -1) return; // Should not happen

      let entry = index.entries[entryIndex];

      // Initialize SRS fields if they don't exist
      entry.easiness = entry.easiness || 2.5;
      entry.repetitions = entry.repetitions || 0;
      entry.interval = entry.interval || 0;

      // SM-2 Algorithm
      if (quality >= 3) {
        // Correct response
        if (entry.repetitions === 0) {
          entry.interval = 1;
        } else if (entry.repetitions === 1) {
          entry.interval = 6;
        } else {
          entry.interval = Math.round(entry.interval * entry.easiness);
        }
        entry.repetitions += 1;
      } else {
        // Incorrect response
        entry.repetitions = 0;
        entry.interval = 1;
      }

      entry.easiness = entry.easiness + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (entry.easiness < 1.3) {
        entry.easiness = 1.3;
      }

      const dueDate = new Date();
      dueDate.setDate(dueDate.getDate() + entry.interval);
      dueDate.setHours(0, 0, 0, 0);
      entry.due_date = dueDate.toISOString();
      
      index.entries[entryIndex] = entry;

      const KNOWLEDGE_BASE_PATH = path.join(process.env.HOME, '.claude', 'knowledge');
      fs.writeFileSync(path.join(KNOWLEDGE_BASE_PATH, 'search-index.json'), JSON.stringify(index, null, 2));

      return {
        feedback: tools.parse_evaluation.result.feedback,
        next_review: dueDate.toLocaleDateString(),
        interval: entry.interval,
        easiness: entry.easiness.toFixed(2)
      };

  - tool: user_output
    content: |
      **✅ 评估反馈:**
      {{update_srs.result.feedback}}
      
      ---
      **💡 学习状态更新:**
      - **下次复习:** {{update_srs.result.next_review}}
      - **复习间隔:** {{update_srs.result.interval}} 天
      - **简易度:** {{update_srs.result.easiness}}
      
      继续努力！💪
      
- tool: user_output
  content: "{{process_quiz_logic.result}}"
  skip_if: "{{!process_quiz_logic.result || process_quiz_logic.result.entry}}"
---

# Knowledge Base - Quiz

## Overview

Generate a short, interactive quiz based on the content of a knowledge entry. This helps reinforce learning through active recall.

## Argument Parsing

- Parse `$ARGUMENTS` to get the **entry name**.
- The command is `/kb-quiz <entry-name>`.

## Workflow

1.  **Find Entry**: Locate the entry's markdown file using the same logic as `/kb-detail` (search index first, then fallback to file system scan). If not found, notify the user.
2.  **Read Content**: Read the entire content of the entry's `.md` file.
3.  **Generate Questions**: Based on the text, generate 3-5 quiz questions. The questions should be a mix of multiple-choice and open-ended questions to test different aspects of understanding.
    *   **Multiple-Choice**: Should have one correct answer and 2-3 plausible distractors.
    *   **Open-Ended**: Should ask for a definition, explanation, or a short code example.
4.  **Present Quiz**: Use the `AskUserQuestion` tool to present the questions one by one. Do not reveal the answers upfront.
5.  **Collect Answers**: Store the user's answers.
6.  **Provide Feedback**: After the user has answered all questions, display their answers alongside the correct answers and provide a brief explanation for each, especially for the ones they got wrong.
7.  **Update Profile (Optional)**: If the user scores poorly on a topic they previously rated as "mastered" in their `profile.md`, you could suggest they review the topic or lower their self-assessed score.

## Question Generation Guidelines

- **Focus on Key Concepts**: Questions should target the most important concepts, definitions, and use cases mentioned in the entry.
- **Vary Difficulty**: Include both straightforward recall questions and slightly more challenging questions that require some inference.
- **Source from All Sections**: Generate questions from both the initial summary and the deep-dive sections to ensure comprehensive coverage.
- **Avoid Trivial Questions**: Don't ask about things that are obvious or not central to understanding the topic.

## Example Interaction

**User**: `/kb-quiz decorators`

**Agent**: (Finds `decorators.md`, reads content, and generates questions)

**(Using AskUserQuestion)**
> **Question 1/3 (Multiple Choice):** What is the primary purpose of a decorator in Python?
> - A) To add comments to code
> - B) To modify or enhance a function or class without changing its source code
> - C) To delete a function
> - D) To rename a variable

**(User answers, then the next question is presented)**

**(After all questions are answered)**
> **Quiz Results for "Decorators":**
>
> **1. What is the primary purpose of a decorator in Python?**
> - **Your Answer:** B) To modify or enhance a function or class...
> - **Correct Answer:** B)
> - ✅ Correct!
>
> **2. (Open-Ended) How do you apply a decorator to a function?**
> - **Your Answer:** "You use the @ symbol"
> - **Correct Answer:** You apply it by placing the decorator's name preceded by the `@` symbol on the line directly above the function definition.
> - ✅ Correct!
>
> **You got 2 out of 3 correct. Great job!**
> You seem to have a good grasp of the basics. For a deeper dive, you might want to review the section on "Decorator with Arguments".
