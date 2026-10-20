#!/usr/bin/env bash
# Flutter Bot Team Kit installer for Cursor and/or Claude Code.
# No network, no git. Use --dry-run to preview (writes nothing).
set -euo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"
. "$KIT/install/lib.sh"
DRY=0; [[ "${1:-}" == "--dry-run" ]] && DRY=1
ask(){ local q="$1" d="$2" a; read -r -p "$q [$d]: " a || true; echo "${a:-$d}"; }
yn(){ local a; a=$(ask "$1 (y/n)" "$2"); [[ "$a" =~ ^[Yy] ]]; }
mk(){ if [[ $DRY -eq 1 ]]; then echo "DRY: mkdir $1"; else mkdir -p "$1"; fi; }
SUBS=()
subst(){ sed -e "s#<AI-ROOT>#$AIROOT#g" -e "s#<App-Name>#$APP#g" -e "s#the owner#$OWNER#g"; }
# write <dst> : reads stdin, applies placeholders
write(){ if [[ $DRY -eq 1 ]]; then cat >/dev/null; echo "DRY: write $1"; else subst > "$1"; fi; }

echo "== Flutter Bot Team Kit setup =="
TARGET=$(ask "Target (cursor/claude/both)" "both")
SCOPE=$(ask "Scope (global/project)" "global")
REPO=""
if [[ "$SCOPE" == project ]]; then REPO=$(ask "Project repo path" "$PWD"); fi
OWNER=$(ask "Your name" "the owner")
APP=$(ask "App name" "MyApp")
DOMAIN=$(ask "Domain (fintech/telecom/other)" "other")
STATE=$(ask "State management (GetX/Bloc/Riverpod)" "GetX")
ARCH=$(ask "Architecture (clean/legacy/mixed)" "mixed")
FVM=$(ask "Use fvm (yes/no)" "yes")
TRACKER=$(ask "Tracker (Jira/Linear/none)" "Jira")
AIROOT=$(ask "AI-ROOT path" "$HOME/ai-root")
CURSOR_STRONG=auto
if [[ "$TARGET" != claude ]]; then CURSOR_STRONG=$(ask "Cursor model for strong-tier bots (auto or model name)" "auto"); fi

OPT=()
for f in "$KIT"/agents/optional/*.md; do
  n=$(basename "$f" .md); if yn "Install optional bot $n" "n"; then OPT+=("$f"); fi
done
AGENT_FILES=("$KIT"/agents/core/*.md ${OPT[@]+"${OPT[@]}"})

skip_skill(){ [[ "$ARCH" == clean && $1 == flutter-legacy-edit ]] || [[ "$ARCH" == legacy && $1 == flutter-clean-feature ]]; }

install_for(){ # <cursor|claude>
  local tool="$1" base
  if [[ "$SCOPE" == project ]]; then base="$REPO/.$tool"; else base="$HOME/.$tool"; fi
  mk "$base/agents"; mk "$base/skills"
  for f in "${AGENT_FILES[@]}"; do emit_agent "$f" "$tool" "$CURSOR_STRONG" | write "$base/agents/$(basename "$f")"; done
  for d in "$KIT"/skills/*/*/; do
    local n; n=$(basename "$d"); skip_skill "$n" && continue
    mk "$base/skills/$n"
    for f in "$d"*; do write "$base/skills/$n/$(basename "$f")" < "$f"; done
  done
  if [[ "$tool" == cursor ]]; then
    if [[ -n "$REPO" ]]; then mk "$REPO/.cursor/rules"
      { emit_cursor_rule "$KIT/AGENTS.md"; echo; echo "Stack: $STATE, $ARCH. fvm: $FVM. Tracker: $TRACKER."; } | write "$REPO/.cursor/rules/team.mdc"
    else echo "Note: Cursor rules are per project. Re-run with scope=project or copy .cursor/rules/team.mdc to your repo."; fi
  else
    mk "$base/commands"
    for f in "$KIT"/.claude/commands/*.md; do write "$base/commands/$(basename "$f")" < "$f"; done
    if [[ -n "$REPO" ]]; then
      { cat "$KIT/AGENTS.md"; echo; echo "Stack: $STATE, $ARCH. fvm: $FVM. Tracker: $TRACKER."; } | write "$REPO/AGENTS.md"
      if [[ -f "$REPO/CLAUDE.md" && $DRY -eq 0 ]]; then grep -q '@AGENTS.md' "$REPO/CLAUDE.md" || printf "\n@AGENTS.md\n" >> "$REPO/CLAUDE.md"
      else write "$REPO/CLAUDE.md" < "$KIT/CLAUDE.md"; fi
      [[ -f "$REPO/.claude/settings.json" ]] || write "$REPO/.claude/settings.json" < "$KIT/.claude/settings.example.json"
    else
      write "$base/team-AGENTS.md" < "$KIT/AGENTS.md"
      echo "Note: add '@~/.claude/team-AGENTS.md' to ~/.claude/CLAUDE.md, and merge .claude/settings.example.json into ~/.claude/settings.json."
    fi
  fi
}

case "$TARGET" in
  cursor) install_for cursor ;;
  claude) install_for claude ;;
  both)   install_for cursor; install_for claude ;;
  *) echo "Unknown target: $TARGET" >&2; exit 1 ;;
esac

# Shared cache for the app
mk "$AIROOT/$APP/tasks"; mk "$AIROOT/$APP/project"
for d in contracts templates project-overrides; do
  if [[ $DRY -eq 1 ]]; then echo "DRY: copy $d -> $AIROOT/$APP/"; else cp -R "$KIT/$d" "$AIROOT/$APP/"; fi
done
DF="$KIT/domains/$DOMAIN/DOMAIN.md"; [[ -f "$DF" ]] || DF="$KIT/domains/_template/DOMAIN.md"
write "$AIROOT/$APP/DOMAIN.md" < "$DF"
echo "Done ($TARGET, $SCOPE). Cursor: @captain build-feature <JIRA-KEY>. Claude Code: /build-feature <JIRA-KEY>"
