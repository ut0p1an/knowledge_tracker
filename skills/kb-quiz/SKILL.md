---
name: kb-quiz
description: Generate a short quiz for a knowledge entry to test understanding.
argument-hint: <entry-name>
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
