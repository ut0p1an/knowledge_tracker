# Knowledge Tracker for Claude Code

[中文版](README.md)

A knowledge gap tracking system for Claude Code. Automatically identifies and collects unfamiliar knowledge points during vibe coding, builds a personal knowledge base with categorized management, knowledge linking, and on-demand learning.

## Features

- **Auto Collection**: Claude proactively identifies your knowledge gaps during coding and records them (opt-in, requires CLAUDE.md configuration)
- **Manual Tagging**: Use `/learn <topic>` to tag any knowledge point of interest at any time
- **Knowledge Linking**: Bidirectional links between entries build a knowledge graph (auto-suggested on creation + `/kb 关联` for manual linking)
- **Categorized Management**: Entries organized by domain (category), with type (技/道) as a metadata tag
- **On-demand Learning**: Switch between simplified and in-depth explanations, original entries remain untouched, with optional focus direction
- **Structured Index**: Automatically maintains search-index.json for tag-based search and quick retrieval
- **Index Recovery**: Use `/kb 修复` to rebuild indexes from filesystem, fixing inconsistencies
- **Knowledge Profile**: Build and maintain your knowledge capability model through self-assessment + quizzes
- **Global Effect**: Shared across projects, knowledge base accumulates continuously

## Skills List

| Command | Description |
| --- | --- |
| `/learn <topic>` | Manually tag a knowledge point |
| `/kb` | Unified knowledge base entry. Use natural language to describe intent: |
| | — `/kb` browse catalog / `/kb <entry>` view details |
| | — `/kb 深入 <entry> [direction]` append deep dive |
| | — `/kb 测验 [entry]` spaced-repetition quiz / `/kb 测验 统计` view review stats |
| | — `/kb 关联 <A> <B>` create bidirectional link |
| | — `/kb 删除 <entry>` delete entry |
| | — `/kb 评估` knowledge profile assessment / `/kb 修复` rebuild index |

Additionally, `knowledge-collector` (requires opt-in config) and `knowledge-profile` are automatically triggered by Claude during coding and do not need to be invoked manually.

## Installation

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

### Manual Installation

If the scripts don't work for you, just copy manually:

```bash
# Copy skills
cp -r skills/* ~/.claude/skills/

# Create knowledge base directory and copy templates
mkdir -p ~/.claude/knowledge
cp knowledge-template/INDEX.md ~/.claude/knowledge/
cp knowledge-template/profile.md ~/.claude/knowledge/
cp knowledge-template/assess-history.json ~/.claude/knowledge/
cp knowledge-template/search-index.json ~/.claude/knowledge/
```

**Restart Claude Code** after installation for skills to take effect.

## Usage Guide

### 1. Initialize Knowledge Profile

After first installation, run the self-assessment questionnaire:

```
/kb 评估
```

Claude will ask about your role, experience, and provide assessment questions for various domains to build your knowledge profile.

### 2. Daily Usage

Just proceed with vibe coding as usual. If you've enabled auto-collection (see Configuration below), Claude will work in the background to:
- Identify knowledge gaps based on your questions and coding style
- Automatically record and provide a one-line notification when confidence is high

You can also manually tag at any time:

```
/learn FastAPI dependency injection
/learn CAP theorem
```

When creating entries, the system automatically scans existing entries and suggests possible links.

### 3. View and Manage Knowledge Base

```
```
/kb                                    # Browse catalog with action guide
/kb python                             # Filter by category
/kb metaprogramming                    # Filter by tag
/kb asyncio                            # View entry details
/kb 深入 asyncio                        # Append deep dive
/kb 深入 asyncio multithreading interop # Deep dive with focus direction
/kb 测验                                # Auto-select due entry for quiz
/kb 测验 asyncio                        # Quiz on specific entry
/kb 关联 decorators metaprogramming     # Link two entries
/kb 删除 asyncio                        # Delete (requires confirmation)
/kb 评估                                # Refresh knowledge profile
/kb 修复                                # Rebuild index
```
```

### 4. Manage Knowledge Links

```
/kb 关联 decorators metaprogramming    # Create bidirectional link
```

The system reads both entries' content to judge relevance:
- Clearly related → creates bidirectional link directly
- Questionable relevance → warns and asks for confirmation

### 5. Refresh Knowledge Profile

As your learning progresses, refresh your profile periodically:

```
/kb 评估
```

The system avoids repeating previously asked questions and only generates new assessment items.

## Knowledge Entry Format

### Skill Entries (技)

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

## What It Is (one sentence)
## Use Cases
## Basic Usage
## Common Pitfalls
```

`/kb 深入` generated deep dives are appended directly to the original entry file. Multiple deep dives accumulate without creating separate files.

### Principle Entries (道)

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

## Concept Overview
## Related Fields
## Prerequisites
## Deep Dive Directions
```

## Configuration

### Enable Auto-Collection (Optional)

Add the following to your project or global CLAUDE.md to enable automatic knowledge collection:

```markdown
# Knowledge Tracker Settings
knowledge-collector: true
```

Without this config, you can only collect knowledge manually via `/learn`.

### Behavior Variables

Adjustable in `skills/knowledge-collector/SKILL.md`:

```yaml
AUTO_NOTIFY_ONLY: true       # true = only notify (no prompt) when confidence is high
BACKGROUND_EXPLAIN: true     # true = generate detailed content in background
```

## File Structure

```
~/.claude/
├── skills/                          # Skills directory
│   ├── kb/SKILL.md                   # /kb unified router (browse/view/deep dive/quiz/link/delete/assess/rebuild)
│   ├── learn/SKILL.md                # /learn manual knowledge tagging
│   ├── knowledge-collector/SKILL.md  # Auto-detect knowledge gaps (opt-in, requires config)
│   └── knowledge-profile/SKILL.md
│
└── knowledge/                       # Knowledge base data
    ├── INDEX.md                     # Master catalog (Markdown, human-readable)
    ├── search-index.json            # Structured index (for machine retrieval)
    ├── profile.md                   # Knowledge profile
    ├── assess-history.json          # Assessment history (avoid duplicates)
    └── {category}/                  # Entries organized by domain
        └── {topic}.md               # Entry file (summary + accumulated deep dives)
```

### search-index.json Structure

A structured index automatically maintained when entries are added or removed, used for quick retrieval, tag filtering, and profile linkage:

```json
{
  "version": 1,
  "last_updated": "2026-05-20",
  "entries": [
    {
      "id": "decorators",
      "type": "技",
      "category": "python",
      "title": "Python Decorators",
      "tags": ["python", "functions", "metaprogramming"],
      "related": ["metaprogramming", "context-managers"],
      "profile_domains": ["python"],
      "level": "brief",
      "has_detailed": false,
      "has_simplified": false,
      "status": "new",
      "path": "python/decorators.md",
      "created": "2026-05-20",
      "summary": "Wrap functions with @syntax to add extra behavior"
    }
  ]
}
```

Field descriptions:
| Field | Description |
| --- | --- |
| `id` | Entry identifier (filename without .md) |
| `type` | "技" (skill) or "道" (principle), from frontmatter |
| `category` | Domain directory name |
| `tags` | Keywords for search and filtering |
| `related` | List of linked entry IDs (bidirectional, synced with frontmatter `links`) |
| `profile_domains` | Corresponding domains in the knowledge profile |
| `level` | Original entry detail level: brief (default) |
| `has_detailed` | Whether a .detailed.md file exists |
| `has_simplified` | Whether a .simplified.md file exists |
| `status` | new (newly added) or reviewed (already reviewed) |
| `path` | File path relative to knowledge/ |
| `summary` | One-sentence summary |

## Uninstall

```bash
# Remove skills
rm -rf ~/.claude/skills/kb
rm -rf ~/.claude/skills/learn
rm -rf ~/.claude/skills/knowledge-collector
rm -rf ~/.claude/skills/kb-list
rm -rf ~/.claude/skills/kb-detail
rm -rf ~/.claude/skills/kb-delete
rm -rf ~/.claude/skills/kb-simplify
rm -rf ~/.claude/skills/kb-deep
rm -rf ~/.claude/skills/kb-link
rm -rf ~/.claude/skills/kb-quiz
rm -rf ~/.claude/skills/kb-assess
rm -rf ~/.claude/skills/kb-rebuild-index
rm -rf ~/.claude/skills/knowledge-profile

# Remove knowledge base data (caution! This will delete all collected knowledge)
rm -rf ~/.claude/knowledge
```

## Compatibility

- Claude Code CLI
- Requires Claude Code support for `~/.claude/skills/` custom skill loading

## Contributing

Issues and PRs are welcome:
- New knowledge entry templates
- Improved auto-detection logic
- New management commands
- Internationalization support

## License

MIT
