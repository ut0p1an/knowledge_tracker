# Knowledge Tracker for Claude Code

[中文版](README.md)

A knowledge gap tracking system for Claude Code. Automatically identifies and collects unfamiliar knowledge points during vibe coding, builds a personal knowledge base with categorized management and on-demand learning.

## Features

- **Auto Collection**: Claude proactively identifies your knowledge gaps during coding and records them (opt-in, requires CLAUDE.md configuration)
- **Manual Tagging**: Use `/learn <topic>` to tag any knowledge point of interest at any time
- **Categorized Management**: Knowledge is divided into two categories: "术" (Practical Skills) and "道" (Principles & Theory)
- **On-demand Learning**: Switch between simplified and in-depth explanations, original entries remain untouched, with optional focus direction
- **Structured Index**: Automatically maintains search-index.json for tag-based search and quick retrieval
- **Index Recovery**: Use `/kb-rebuild-index` to rebuild indexes from filesystem, fixing inconsistencies
- **Knowledge Profile**: Build and maintain your knowledge capability model through self-assessment + quizzes
- **Global Effect**: Shared across projects, knowledge base accumulates continuously

## Skills List

| Command | Description |
| --- | --- |
| `/learn <topic>` | Manually tag a knowledge point |
| `/kb-list [category] [--tag <tag>]` | View knowledge base catalog (supports tag filtering) |
| `/kb-detail <entry>` | View specific entry content |
| `/kb-delete <entry>` | Delete an entry |
| `/kb-simplify <entry> [direction]` | Simplified explanation (with optional focus direction) |
| `/kb-deep <entry> [direction]` | In-depth explanation (with optional focus direction) |
| `/kb-assess` | Self-assessment questionnaire (initialize/refresh knowledge profile, supports batch testing) |
| `/kb-rebuild-index` | Rebuild index from filesystem (fix inconsistencies) |

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

# Create knowledge base directories and copy templates
mkdir -p ~/.claude/knowledge/技 ~/.claude/knowledge/道
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
/kb-assess
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

### 3. View and Manage Knowledge Base

```
/kb-list                    # View full catalog (with summaries)
/kb-list python             # View python category (with tags and summaries)
/kb-list --tag metaprogramming  # Filter entries by tag
/kb-detail asyncio          # View specific entry
/kb-simplify asyncio        # Simplified version
/kb-simplify asyncio syntax only           # Simplified, focused on syntax
/kb-deep asyncio            # In-depth version
/kb-deep asyncio multithreading interop    # In-depth, focused on multithreading
/kb-delete asyncio          # Delete
```

### 4. Refresh Knowledge Profile

As your learning progresses, refresh your profile periodically:

```
/kb-assess
```

The system avoids repeating previously asked questions and only generates new assessment items.

## Knowledge Entry Format

### "术" Entries (Practical Skills)

```markdown
---
type: 技
category: python
created: 2026-05-19
level: brief
status: new | reviewed
---
# Topic Name

## What It Is (one sentence)
## Use Cases
## Basic Usage
## Common Pitfalls
```

In-depth (`/kb-deep`) and simplified (`/kb-simplify`) versions are saved as separate files and do not overwrite the original entry.

### "道" Entries (Principles & Theory)

```markdown
---
type: 道
category: distributed-systems
created: 2026-05-19
level: brief
status: new | reviewed
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
│   ├── knowledge-collector/SKILL.md  # Auto-detect knowledge gaps (opt-in, requires config)
│   ├── learn/SKILL.md                # /learn manual knowledge tagging
│   ├── kb-list/SKILL.md
│   ├── kb-detail/SKILL.md
│   ├── kb-delete/SKILL.md
│   ├── kb-simplify/SKILL.md
│   ├── kb-deep/SKILL.md
│   ├── kb-assess/SKILL.md
│   ├── kb-rebuild-index/SKILL.md     # /kb-rebuild-index rebuild index
│   └── knowledge-profile/SKILL.md
│
└── knowledge/                       # Knowledge base data
    ├── INDEX.md                     # Master catalog (Markdown, human-readable)
    ├── search-index.json            # Structured index (for machine retrieval)
    ├── profile.md                   # Knowledge profile
    ├── assess-history.json          # Assessment history (avoid duplicates)
    ├── 技/                          # Practical skills
    │   └── {category}/
    │       ├── {topic}.md            # Original entry (brief)
    │       ├── {topic}.detailed.md   # In-depth version (/kb-deep)
    │       └── {topic}.simplified.md # Simplified version (/kb-simplify)
    └── 道/                          # Principles & theory
        └── {category}/
            ├── {topic}.md
            ├── {topic}.detailed.md
            └── {topic}.simplified.md
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
      "related": ["context-managers"],
      "profile_domains": ["python"],
      "level": "brief",
      "status": "new",
      "path": "技/python/decorators.md",
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
| `type` | "技" (skill) or "道" (principle) |
| `category` | Subcategory directory name |
| `tags` | Keywords for search and filtering |
| `related` | List of related entry IDs |
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
