#!/usr/bin/env bash
# Regenerates the tool adapters (.cursor/ and .claude/) from the tool-neutral sources.
# Run after editing agents/ or AGENTS.md. No network, no git.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"
. "$KIT/install/lib.sh"
rm -rf "$KIT/.cursor/agents" "$KIT/.claude/agents"
mkdir -p "$KIT/.cursor/rules" "$KIT/.cursor/agents" "$KIT/.claude/agents"
emit_cursor_rule "$KIT/AGENTS.md" > "$KIT/.cursor/rules/team.mdc"
for f in "$KIT"/agents/*/*.md; do
  n=$(basename "$f")
  emit_agent "$f" cursor auto > "$KIT/.cursor/agents/$n"
  emit_agent "$f" claude    > "$KIT/.claude/agents/$n"
done
echo "Adapters regenerated: .cursor/rules/team.mdc, .cursor/agents/, .claude/agents/"
