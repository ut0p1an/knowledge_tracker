#!/bin/bash
# Knowledge Tracker Plugin - Uninstall Script

set -e

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
KNOWLEDGE_DIR="$CLAUDE_DIR/knowledge"

echo "================================================"
echo "  Knowledge Tracker Plugin - Uninstaller"
echo "================================================"
echo ""

# Remove skills
echo "[1/2] Removing skills..."
for skill in knowledge-collector learn kb kb-list kb-detail kb-delete kb-simplify kb-deep kb-link kb-quiz kb-assess kb-rebuild-index knowledge-profile; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        rm -rf "$SKILLS_DIR/$skill"
        echo "      - $skill"
    fi
done
echo "      Done."
echo ""

# Ask about knowledge data
echo "[2/2] Knowledge base data..."
echo ""
echo "  Your knowledge data is at: $KNOWLEDGE_DIR"
echo "  This contains your collected knowledge entries and profile."
echo ""
read -p "  Delete knowledge data too? (y/N): " confirm
if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    rm -rf "$KNOWLEDGE_DIR"
    echo "      Knowledge data deleted."
else
    echo "      Knowledge data preserved at $KNOWLEDGE_DIR"
fi

echo ""
echo "================================================"
echo "  Uninstall complete. Restart Claude Code."
echo "================================================"
echo ""
