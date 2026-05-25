---
name: knowledge-profile
description: Use during coding sessions to maintain awareness of user knowledge level. Reads profile before assessing knowledge gaps. Not user-invocable - Claude uses this internally.
user-invocable: false
---

# Knowledge Profile Manager

## Overview

Internal skill that maintains the user's knowledge profile. Claude reads this before deciding whether to collect a knowledge point.

## Path Resolution

The knowledge base root (`KB_ROOT`) is:
- Linux/macOS: `$HOME/.claude/knowledge`
- Windows: `$env:USERPROFILE\.claude\knowledge`

Profile is at `{KB_ROOT}/profile.md`.

## When to Activate

- Before `knowledge-collector` auto-detection decisions
- After any knowledge entry is added or deleted
- After `/kb-assess` completes

## Core Rules

1. **Always read profile before judging gaps**: Load `{KB_ROOT}/profile.md` to understand what the user already knows.

2. **Update profile incrementally**: When you observe the user demonstrating knowledge in a domain:
   - Upgrade their rating if they show deeper understanding than recorded
   - Add notes about specific sub-topics they've mastered

3. **Never downgrade without evidence**: Don't reduce a user's rating based on a single mistake. Only downgrade if they explicitly ask to reassess.

4. **Track learning progress**: When a user uses `/kb-detail` or `/kb-deep` and demonstrates understanding in subsequent coding, mark the entry status as `reviewed`.

## Profile Update Triggers

| Event | Action |
|-------|--------|
| User writes idiomatic code in a domain rated < 4 | Consider upgrading |
| User asks basic question in a domain rated > 3 | Note but don't downgrade |
| User completes `/kb-assess` | Full profile rewrite |
| Knowledge entry deleted by user | Remove from 待学习 |
| New knowledge entry created | Add to 待学习 if new domain |

## Inference Guidelines

When coding with the user, infer knowledge level from:
- Questions they ask (or don't ask)
- Code patterns they use (idiomatic vs. textbook vs. confused)
- Frameworks they choose and how they configure them
- Error patterns and how they debug

Do NOT infer from:
- Typos or autocomplete mistakes
- Copy-paste from docs (doesn't mean they understand)
- One-off experiments

## Integration with knowledge-collector

Before auto-recording a knowledge point, check:
1. Is this domain in their "熟练领域"? → Skip, they probably know it
2. Is this domain in "了解但不深入"? → Record only if it's clearly advanced
3. Is this domain in "初步接触" or unlisted? → Record with higher confidence
