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
echo "[1/4] Installing skills..."
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
echo "[2/4] Setting up knowledge base..."
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

# Configure permissions
echo "[3/4] Configuring permissions..."
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
REQUIRED_RULES=(
    'Read(~/.claude/knowledge/**)'
    'Write(~/.claude/knowledge/**)'
    'Edit(~/.claude/knowledge/**)'
    'Bash(mkdir:~/.claude/knowledge/*)'
)

if [ -f "$SETTINGS_FILE" ]; then
    if command -v python3 &>/dev/null; then
        python3 -c "
import json, sys

settings_path = sys.argv[1]
rules = sys.argv[2:]

with open(settings_path, 'r', encoding='utf-8') as f:
    settings = json.load(f)

if 'permissions' not in settings:
    settings['permissions'] = {}
if 'allow' not in settings['permissions']:
    settings['permissions']['allow'] = []

existing = settings['permissions']['allow']
added = 0
for rule in rules:
    if rule not in existing:
        existing.append(rule)
        print(f'      + {rule}')
        added += 1
    else:
        print(f'      {rule} (already exists)')

with open(settings_path, 'w', encoding='utf-8') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')

print(f'      Done. ({added} rules added to settings.json)')
" "$SETTINGS_FILE" "${REQUIRED_RULES[@]}"
    elif command -v jq &>/dev/null; then
        ADDED=0
        for rule in "${REQUIRED_RULES[@]}"; do
            HAS_RULE=$(jq --arg r "$rule" '.permissions.allow // [] | map(select(. == $r)) | length' "$SETTINGS_FILE" 2>/dev/null || echo "0")
            if [ "$HAS_RULE" = "0" ]; then
                TEMP=$(mktemp)
                jq --arg r "$rule" '
                    .permissions //= {} |
                    .permissions.allow //= [] |
                    .permissions.allow += [$r]
                ' "$SETTINGS_FILE" > "$TEMP" && mv "$TEMP" "$SETTINGS_FILE"
                echo "      + $rule"
                ADDED=$((ADDED + 1))
            else
                echo "      $rule (already exists)"
            fi
        done
        echo "      Done. ($ADDED rules added to settings.json)"
    else
        echo "      [WARN] Neither python3 nor jq found." >&2
        echo "      Please manually add these permissions to $SETTINGS_FILE:"
        for rule in "${REQUIRED_RULES[@]}"; do
            echo "        - $rule"
        done
    fi
else
    echo "      [WARN] settings.json not found, skipping permissions."
    echo "      You may need to manually allow access to ~/.claude/knowledge/"
fi
echo ""

# Summary
echo "[4/4] Verifying installation..."
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
