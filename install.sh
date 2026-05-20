#!/bin/bash
# Knowledge Tracker Plugin - Install Script
# Supports Linux, macOS, and Windows (Git Bash / MSYS2)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
KNOWLEDGE_DIR="$CLAUDE_DIR/knowledge"

echo "================================================"
echo "  Knowledge Tracker Plugin - Installer"
echo "================================================"
echo ""

# Check if .claude directory exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "[!] ~/.claude directory not found."
    echo "    Please make sure Claude Code is installed first."
    exit 1
fi

# Check for existing skills and warn
EXISTING_SKILLS=0
for skill in knowledge-collector learn kb-list kb-detail kb-delete kb-simplify kb-deep kb-assess knowledge-profile; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        EXISTING_SKILLS=$((EXISTING_SKILLS + 1))
    fi
done

if [ $EXISTING_SKILLS -gt 0 ]; then
    echo "[!] Found $EXISTING_SKILLS existing knowledge-tracker skills."
    read -p "    Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "    Installation cancelled."
        exit 0
    fi
    echo ""
fi

# Install skills
echo "[1/3] Installing skills..."
mkdir -p "$SKILLS_DIR"

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$SKILLS_DIR/$skill_name"
    cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/SKILL.md"
    echo "      + $skill_name"
done

echo "      Done. ($( ls -d "$SCRIPT_DIR"/skills/*/ | wc -l | tr -d ' ') skills installed)"
echo ""

# Install knowledge base template
echo "[2/3] Setting up knowledge base..."
mkdir -p "$KNOWLEDGE_DIR/技" "$KNOWLEDGE_DIR/道"

if [ -f "$KNOWLEDGE_DIR/INDEX.md" ]; then
    echo "      INDEX.md already exists, skipping (won't overwrite your data)"
else
    cp "$SCRIPT_DIR/knowledge-template/INDEX.md" "$KNOWLEDGE_DIR/INDEX.md"
    echo "      + INDEX.md"
fi

if [ -f "$KNOWLEDGE_DIR/profile.md" ]; then
    echo "      profile.md already exists, skipping"
else
    cp "$SCRIPT_DIR/knowledge-template/profile.md" "$KNOWLEDGE_DIR/profile.md"
    echo "      + profile.md"
fi

if [ -f "$KNOWLEDGE_DIR/assess-history.json" ]; then
    echo "      assess-history.json already exists, skipping"
else
    cp "$SCRIPT_DIR/knowledge-template/assess-history.json" "$KNOWLEDGE_DIR/assess-history.json"
    echo "      + assess-history.json"
fi

echo "      Done."
echo ""

# Summary
echo "[3/3] Verifying installation..."
INSTALLED_COUNT=0
for skill in knowledge-collector learn kb-list kb-detail kb-delete kb-simplify kb-deep kb-assess knowledge-profile; do
    if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        echo "      [WARN] $skill not found!"
    fi
done

echo ""
echo "================================================"
echo "  Installation complete!"
echo "================================================"
echo ""
echo "  Skills installed: $INSTALLED_COUNT/9"
echo "  Knowledge base:   $KNOWLEDGE_DIR"
echo ""
echo "  Next steps:"
echo "  1. Restart Claude Code to load new skills"
echo "  2. Run /kb-assess to initialize your knowledge profile"
echo "  3. Start coding - knowledge collection is automatic!"
echo ""
echo "  Commands:"
echo "    /learn <topic>      - Mark a knowledge point"
echo "    /kb-list            - View knowledge catalog"
echo "    /kb-detail <entry>  - View entry details"
echo "    /kb-simplify <entry>- Simplified explanation"
echo "    /kb-deep <entry>    - Deep dive explanation"
echo "    /kb-delete <entry>  - Delete an entry"
echo "    /kb-assess          - Run self-assessment"
echo ""
