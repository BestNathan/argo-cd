#!/bin/bash
# Injects wiki index.md + wiki skill names/descriptions into SessionStart context.
set -euo pipefail

WIKI_DIR="$CLAUDE_PROJECT_DIR/docs/wiki"
[ -d "$WIKI_DIR" ] || exit 0
INDEX="$WIKI_DIR/index.md"
[ -f "$INDEX" ] || exit 0

# Read full index.md
INDEX_CONTENT=$(cat "$INDEX")

# Build skill list from SKILL.md frontmatter
SKILLS=""
SKILLS_PATH="$CLAUDE_PROJECT_DIR/.claude/skills"
if [ -f "$CLAUDE_PROJECT_DIR/.claude" ]; then
  for f in "$SKILLS_PATH"/wiki-*/SKILL.md; do
    name=$(sed -n 's/^name: *//p' "$f")
    desc=$(sed -n 's/^description: *//p' "$f")
    SKILLS+="- **$name**: $desc"$'\n'
  done
fi


CONTEXT="### Wiki Knowledge Base (auto-injected at session start)

$INDEX_CONTENT

### Wiki Skills
$SKILLS"

# Escape for JSON string: backslash, double-quote, control chars
ESCAPED=$(printf '%s' "$CONTEXT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()), end="")')

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$ESCAPED}}"
