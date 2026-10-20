#!/usr/bin/env bash
# Flutter Bot Team Kit installer for Cursor, Claude Code, Codex, Antigravity, Gemini CLI,
# Windsurf, GitHub Copilot, Grok Build and any AGENTS.md agent (generic).
# No network, no git. Use --dry-run to preview (writes nothing).
# Flags: --dry-run, --git=self|bots, --target=<list>|both|all, and the tool flags
# --tracker= --design= --docs= --crash= --quality= (a listed name, other:<Name>, any or none).
# Tool answers only write names into the team rules; the kit has no built-in integrations.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"
. "$KIT/install/lib.sh"
DRY=0; GIT_FLAG=""; TARGET_FLAG=""; TRACKER_FLAG=""; DESIGN_FLAG=""; DOCS_FLAG=""; CRASH_FLAG=""; QUALITY_FLAG=""
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --git=*) GIT_FLAG="${a#--git=}" ;;
    --target=*) TARGET_FLAG="${a#--target=}" ;;
    --tracker=*) TRACKER_FLAG="${a#--tracker=}" ;;
    --design=*) DESIGN_FLAG="${a#--design=}" ;;
    --docs=*) DOCS_FLAG="${a#--docs=}" ;;
    --crash=*) CRASH_FLAG="${a#--crash=}" ;;
    --quality=*) QUALITY_FLAG="${a#--quality=}" ;;
    *) echo "Unknown option: $a (use --dry-run, --git=self|bots, --target=<list>|both|all, --tracker= --design= --docs= --crash= --quality=)" >&2; exit 1 ;;
  esac
done
ask(){ local q="$1" d="$2" a; read -r -p "$q [$d]: " a || true; echo "${a:-$d}"; }
# tool_name <kind> <answer>: display name, none, any, other, or custom:<Name>
tool_name(){
  local k="$1" raw="$2" v
  case "$raw" in other:*|Other:*) echo "custom:${raw#*:}"; return ;; esac
  v=$(echo "$raw" | tr '[:upper:]' '[:lower:]' | tr -d ' _')
  case "$k:$v" in
    *:none|*:no|*:) echo none ;;
    *:any) echo any ;;
    *:other) echo other ;;
    tracker:jira) echo Jira ;;
    tracker:linear) echo Linear ;;
    tracker:clickup) echo ClickUp ;;
    tracker:github|tracker:githubissues|tracker:github-issues) echo "GitHub Issues" ;;
    tracker:azure|tracker:azuredevops|tracker:azure-devops|tracker:ado) echo "Azure DevOps" ;;
    tracker:asana) echo Asana ;;
    design:figma) echo Figma ;;
    design:penpot) echo Penpot ;;
    design:sketch) echo Sketch ;;
    design:zeplin) echo Zeplin ;;
    docs:confluence) echo Confluence ;;
    docs:notion) echo Notion ;;
    docs:googledocs|docs:google-docs|docs:gdocs|docs:google) echo "Google Docs" ;;
    crash:sentry) echo Sentry ;;
    crash:crashlytics|crash:firebase|crash:firebasecrashlytics|crash:firebase-crashlytics) echo "Firebase Crashlytics" ;;
    quality:codacy) echo Codacy ;;
    quality:sonarqube|quality:sonar|quality:sonarcloud) echo SonarQube ;;
    quality:deepsource) echo DeepSource ;;
    *) echo "custom:$raw" ;;
  esac
}
# choose_tool <kind> <flag value> <label> <options> <default>: flag wins, else ask; "other" asks for a name
choose_tool(){
  local val="$2" n
  [[ -n "$val" ]] || val=$(ask "$3 ($4)" "$5")
  n=$(tool_name "$1" "$val")
  if [[ "$n" == other ]]; then
    val=$(ask "$3 name (type it, or press Enter for generic rules)" "other")
    n=$(tool_name "$1" "other:$val"); [[ "$n" == "custom:other" || "$n" == "custom:" ]] && n=other
  fi
  case "$n" in
    custom:*) echo "${n#custom:} (other, generic rules)" ;;
    other) echo "other (generic rules)" ;;
    *) echo "$n" ;;
  esac
}
yn(){ local a; a=$(ask "$1 (y/n)" "$2"); [[ "$a" =~ ^[Yy] ]]; }
mk(){ if [[ $DRY -eq 1 ]]; then echo "DRY: mkdir $1"; else mkdir -p "$1"; fi; }
SUBS=()
ALL_TARGETS="cursor claude codex antigravity gemini windsurf copilot grok generic"
has(){ case " $TARGETS " in *" $1 "*) return 0 ;; esac; return 1; }
subst(){ sed -e "s#<AI-ROOT>#$AIROOT#g" -e "s#<App-Name>#$APP#g" -e "s#the owner#$OWNER#g"; }
# write <dst> : reads stdin, applies placeholders
write(){ if [[ $DRY -eq 1 ]]; then cat >/dev/null; echo "DRY: write $1"; else subst > "$1"; fi; }

echo "== Flutter Bot Team Kit setup =="
if [[ -n "$TARGET_FLAG" ]]; then TARGET="$TARGET_FLAG"; else
  TARGET=$(ask "Target (cursor/claude/both, or a comma list of $ALL_TARGETS, or all)" "both")
fi
# Normalize: comma/space list, "both" = cursor,claude, "all" = every target; fixed install order
TLIST=","
for t in $(echo "$TARGET" | tr ',' ' '); do
  case "$t" in
    both) TLIST="$TLIST,cursor,claude," ;;
    all)  TLIST="$TLIST,$(echo "$ALL_TARGETS" | tr ' ' ','),"  ;;
    *) case " $ALL_TARGETS " in *" $t "*) TLIST="$TLIST,$t," ;; *) echo "Unknown target: $t" >&2; exit 1 ;; esac ;;
  esac
done
TARGETS=""
for t in $ALL_TARGETS; do case "$TLIST" in *",$t,"*) TARGETS="$TARGETS $t" ;; esac; done
TARGETS="${TARGETS# }"
[[ -n "$TARGETS" ]] || { echo "Unknown target: $TARGET" >&2; exit 1; }
SCOPE=$(ask "Scope (global/project)" "global")
REPO=""
if [[ "$SCOPE" == project ]]; then REPO=$(ask "Project repo path" "$PWD"); fi
OWNER=$(ask "Your name" "the owner")
APP=$(ask "App name" "MyApp")
DOMAIN=$(ask "Domain (fintech/telecom/other)" "other")
STATE=$(ask "State management (GetX/Bloc/Riverpod)" "GetX")
ARCH=$(ask "Architecture (clean/legacy/mixed)" "mixed")
FVM=$(ask "Use fvm (yes/no)" "yes")
TRACKER=$(choose_tool tracker "$TRACKER_FLAG" "Tracker" "jira/linear/clickup/github/azure/asana/other/none" "Jira")
DESIGN=$(choose_tool design "$DESIGN_FLAG" "Design source" "figma/penpot/sketch/zeplin/other/any/none" "any")
DOCS=$(choose_tool docs "$DOCS_FLAG" "Docs source" "confluence/notion/google-docs/other/any/none" "any")
CRASH=$(choose_tool crash "$CRASH_FLAG" "Crash tool" "sentry/crashlytics/other/none" "none")
QUALITY=$(choose_tool quality "$QUALITY_FLAG" "Code quality tool" "codacy/sonarqube/deepsource/other/none" "none")
if [[ $DRY -eq 1 ]]; then echo "DRY: tools: Tracker=$TRACKER; Design=$DESIGN; Docs=$DOCS; Crash=$CRASH; Code quality=$QUALITY (names go into the team rules only)"; fi
if [[ -n "$GIT_FLAG" ]]; then GIT_MODE="$GIT_FLAG"; else
  echo "Who handles git?" >&2
  echo "  1) I do git myself (default, bots never commit/push/rebase/tag)" >&2
  echo "  2) Let bots run git (you confirm each commit/push; repo auth such as SSH keys, tokens or GitHub login stays with you and is never asked for or stored)" >&2
  GIT_MODE=$(ask "Git mode (1/2)" "1")
fi
case "$GIT_MODE" in 1|self) GIT_MODE=self ;; 2|bots) GIT_MODE=bots ;; *) echo "Unknown git mode: $GIT_MODE (use self or bots)" >&2; exit 1 ;; esac
if [[ $DRY -eq 1 && "$GIT_MODE" == bots ]]; then echo "DRY: git mode bots: opt-in git rule in AGENTS.md / team.mdc / commands, git allowed after OK in flutter-dev + git-advisor, settings.json keeps git under ask (no commit/push deny)"; fi
AIROOT=$(ask "AI-ROOT path" "$HOME/ai-root")
CURSOR_STRONG=auto
if has cursor; then CURSOR_STRONG=$(ask "Cursor model for strong-tier bots (auto or model name)" "auto"); fi

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
  for f in "${AGENT_FILES[@]}"; do emit_agent "$f" "$tool" "$CURSOR_STRONG" | git_agent "$(basename "$f" .md)" | write "$base/agents/$(basename "$f")"; done
  for d in "$KIT"/skills/*/*/; do
    local n; n=$(basename "$d"); skip_skill "$n" && continue
    mk "$base/skills/$n"
    for f in "$d"*; do write "$base/skills/$n/$(basename "$f")" < "$f"; done
  done
  if [[ "$tool" == cursor ]]; then
    if [[ -n "$REPO" ]]; then mk "$REPO/.cursor/rules"
      { emit_cursor_rule "$KIT/AGENTS.md"; echo; stack_lines; } | git_rules | write "$REPO/.cursor/rules/team.mdc"
    else echo "Note: Cursor rules are per project. Re-run with scope=project or copy .cursor/rules/team.mdc to your repo."; fi
  else
    mk "$base/commands"
    for f in "$KIT"/.claude/commands/*.md; do git_rules < "$f" | write "$base/commands/$(basename "$f")"; done
    if [[ -n "$REPO" ]]; then
      agents_md_once
      if [[ -f "$REPO/CLAUDE.md" && $DRY -eq 0 ]]; then grep -q '@AGENTS.md' "$REPO/CLAUDE.md" || printf "\n@AGENTS.md\n" >> "$REPO/CLAUDE.md"
      else write "$REPO/CLAUDE.md" < "$KIT/CLAUDE.md"; fi
      [[ -f "$REPO/.claude/settings.json" ]] || git_settings < "$KIT/.claude/settings.example.json" | write "$REPO/.claude/settings.json"
    else
      git_rules < "$KIT/AGENTS.md" | write "$base/team-AGENTS.md"
      echo "Note: add '@~/.claude/team-AGENTS.md' to ~/.claude/CLAUDE.md, and merge .claude/settings.example.json into ~/.claude/settings.json."
      if [[ "$GIT_MODE" == bots ]]; then echo "Note (git mode bots): when merging, drop the git commit/push/rebase/tag denies and keep Bash(git *) under ask."; fi
    fi
  fi
}

# ---- Shared helpers for the other tools (emitters live in lib.sh) ----
DONE_KEYS=""
once(){ case "|$DONE_KEYS|" in *"|$1|"*) return 1 ;; esac; DONE_KEYS="$DONE_KEYS|$1"; return 0; }
note(){ echo "Note ($1): $2"; }
# stack_lines: project answers appended to the team rules
stack_lines(){
  local q="$QUALITY"; [[ "$q" == none ]] && q="none (local rules only)"
  echo "Stack: $STATE, $ARCH. fvm: $FVM. Tracker: $TRACKER."
  echo "Tools: design $DESIGN, docs $DOCS, crash $CRASH, code quality $q. Names only, no built-in integrations. With any, other or none, bots work from pasted text, files or links and the generic rules, and never post anywhere without approval."
}
agents_md(){
  { cat "$KIT/AGENTS.md"; echo; stack_lines
    if has generic; then printf '\n## Bot roles (generic agents)\n- No native subagents: when work goes to a bot, read `.agents/bots/<name>.md` and follow it.\n- Commands: `.agents/commands/<name>.md` (build-feature, fix-bug, review, qa-report).\n'; fi
  } | git_rules
}
agents_md_once(){ if once "agents-md"; then agents_md | write "$REPO/AGENTS.md"; fi; }
# write_global_rules <file>: never overwrite a user's own global rules file
write_global_rules(){
  local p="$1" d="${1%/*}"
  mk "$d"
  if [[ -f "$p" ]]; then
    git_rules < "$KIT/AGENTS.md" | write "$d/team-AGENTS.md"
    echo "Note: $p already exists, so the team rules went to $d/team-AGENTS.md. Merge them into $p."
  else git_rules < "$KIT/AGENTS.md" | write "$p"; fi
}
# agents_to <dir> <emitter...> <ext>: one file per bot
agents_to(){
  local dir="$1" ext="$2" f n; shift 2
  mk "$dir"
  for f in "${AGENT_FILES[@]}"; do n=$(basename "$f" .md); "$@" "$f" | git_agent "$n" | write "$dir/$n$ext"; done
}
# agents_as_skills <dir>: bot roles as Agent Skills (tools without custom subagents)
agents_as_skills(){
  local f n; mk "$1"
  for f in "${AGENT_FILES[@]}"; do n=$(basename "$f" .md); mk "$1/$n"; emit_agent_skill "$f" | git_agent "$n" | write "$1/$n/SKILL.md"; done
}
copy_skills(){
  local dst="$1" d n f
  once "skills:$dst" || return 0
  mk "$dst"
  for d in "$KIT"/skills/*/*/; do
    n=$(basename "$d"); skip_skill "$n" && continue
    mk "$dst/$n"
    for f in "$d"*; do write "$dst/$n/$(basename "$f")" < "$f"; done
  done
}
# cmds_to <dir> <emitter> <ext>: the four commands as files
cmds_to(){
  local dir="$1" em="$2" ext="$3" f
  once "cmds:$dir" || return 0
  mk "$dir"
  for f in "$KIT"/.claude/commands/*.md; do "$em" "$f" | git_rules | write "$dir/$(basename "$f" .md)$ext"; done
}
# cmd_skills_to <dir>: the four commands as Agent Skills
cmd_skills_to(){
  local dir="$1" f n
  once "cmdskills:$dir" || return 0
  mk "$dir"
  for f in "$KIT"/.claude/commands/*.md; do
    n=$(basename "$f" .md)
    # A kit skill with the same name (qa-report) already answers /<name>; never overwrite or duplicate it
    if ls -d "$KIT"/skills/*/"$n" >/dev/null 2>&1; then continue; fi
    mk "$dir/$n"; emit_cmd_skill "$f" | git_rules | write "$dir/$n/SKILL.md"
  done
}

install_tool(){ # <codex|antigravity|gemini|windsurf|copilot|grok|generic>
  local tool="$1" R="$REPO" H="$HOME"
  case "$tool:$SCOPE" in
    codex:project)
      agents_md_once
      agents_to "$R/.codex/agents" .toml emit_agent_codex
      copy_skills "$R/.agents/skills"; cmd_skills_to "$R/.agents/skills"
      mk "$R/.codex/rules"; emit_codex_rules | write "$R/.codex/rules/flutter-bot-team.rules"
      note codex "project .codex/ (agents, rules) loads only after you trust the project." ;;
    codex:*)
      write_global_rules "$H/.codex/AGENTS.md"
      agents_to "$H/.codex/agents" .toml emit_agent_codex
      copy_skills "$H/.agents/skills"; cmd_skills_to "$H/.agents/skills"
      mk "$H/.codex/rules"; emit_codex_rules | write "$H/.codex/rules/flutter-bot-team.rules" ;;
    antigravity:project)
      agents_md_once
      agents_to "$R/.agents/agents" .md emit_agent_tool antigravity
      copy_skills "$R/.agents/skills"; cmd_skills_to "$R/.agents/skills"
      note antigravity "no file-based deny list; keep the terminal deny list in Antigravity settings. Safety rules come from AGENTS.md." ;;
    antigravity:*)
      if has gemini; then note antigravity "uses the team rules in ~/.gemini/GEMINI.md (written for Gemini CLI), so no second copy."
      else mk "$H/.gemini/config/rules"; git_rules < "$KIT/AGENTS.md" | emit_rule_antigravity | write "$H/.gemini/config/rules/flutter-bot-team.md"; fi
      agents_to "$H/.gemini/config/agents" .md emit_agent_tool antigravity
      copy_skills "$H/.gemini/config/skills"; cmd_skills_to "$H/.gemini/config/skills"
      note antigravity "the CLI reads global skills from ~/.gemini/antigravity-cli/skills/; copy them there if you use the CLI." ;;
    gemini:project)
      agents_md_once
      if [[ -f "$R/GEMINI.md" && $DRY -eq 0 ]]; then grep -q '@./AGENTS.md' "$R/GEMINI.md" || printf "\n@./AGENTS.md\n" >> "$R/GEMINI.md"
      else printf '# Gemini CLI context\n\nCore team rules live in AGENTS.md:\n\n@./AGENTS.md\n' | write "$R/GEMINI.md"; fi
      agents_to "$R/.gemini/agents" .md emit_agent_tool gemini
      copy_skills "$R/.agents/skills"
      cmds_to "$R/.gemini/commands" emit_cmd_gemini .toml
      note gemini "workspace policies are disabled in Gemini CLI; re-run with scope=global to install ~/.gemini/policies/flutter-bot-team.toml." ;;
    gemini:*)
      write_global_rules "$H/.gemini/GEMINI.md"
      agents_to "$H/.gemini/agents" .md emit_agent_tool gemini
      copy_skills "$H/.agents/skills"
      cmds_to "$H/.gemini/commands" emit_cmd_gemini .toml
      mk "$H/.gemini/policies"; emit_gemini_policy | write "$H/.gemini/policies/flutter-bot-team.toml" ;;
    windsurf:project)
      agents_md_once
      agents_as_skills "$R/.windsurf/skills"
      copy_skills "$R/.agents/skills"
      cmds_to "$R/.windsurf/workflows" emit_cmd_windsurf .md
      note windsurf "no custom subagents: each bot is a skill (@<bot-name>). No file-based deny list; set it in Windsurf settings." ;;
    windsurf:*)
      write_global_rules "$H/.codeium/windsurf/memories/global_rules.md"
      agents_as_skills "$H/.codeium/windsurf/skills"
      copy_skills "$H/.agents/skills"
      cmds_to "$H/.codeium/windsurf/global_workflows" emit_cmd_windsurf .md ;;
    copilot:project)
      agents_md_once
      agents_to "$R/.github/agents" .agent.md emit_agent_tool copilot
      copy_skills "$R/.agents/skills"
      cmds_to "$R/.github/prompts" emit_cmd_copilot .prompt.md
      note copilot "no repo deny list file; keep terminal auto-approve off in VS Code. Safety rules come from AGENTS.md." ;;
    copilot:*)
      agents_to "$H/.copilot/agents" .agent.md emit_agent_tool copilot
      copy_skills "$H/.agents/skills"
      note copilot "personal instructions and prompt files live in GitHub / VS Code settings, so they were not written. Use scope=project for AGENTS.md and .github/prompts/." ;;
    grok:project)
      agents_md_once
      if has claude; then note grok "reuses .claude/agents and .claude/skills (Grok reads them), so no duplicates were written."
      else agents_to "$R/.grok/agents" .md emit_agent_tool grok; copy_skills "$R/.grok/skills"; fi
      cmd_skills_to "$R/.grok/skills"
      if [[ -f "$R/.grok/config.toml" ]]; then note grok "$R/.grok/config.toml exists; add the [permission] rules yourself (see install/INSTALL.md)."
      else mk "$R/.grok"; emit_grok_config | write "$R/.grok/config.toml"; fi ;;
    grok:*)
      write_global_rules "$H/.grok/AGENTS.md"
      if has claude; then note grok "reuses ~/.claude/agents and ~/.claude/skills (Grok reads them), so no duplicates were written."
      else agents_to "$H/.grok/agents" .md emit_agent_tool grok; copy_skills "$H/.grok/skills"; fi
      cmd_skills_to "$H/.grok/skills"
      note grok "~/.grok/config.toml is your personal config and was not touched; add the [permission] rules from a project install if you want them globally." ;;
    generic:project)
      agents_md_once
      agents_to "$R/.agents/bots" .md emit_agent_tool generic
      copy_skills "$R/.agents/skills"
      cmds_to "$R/.agents/commands" emit_cmd_generic .md ;;
    generic:*)
      note generic "no standard global location; re-run with scope=project." ;;
  esac
}

for t in $TARGETS; do
  case "$t" in
    cursor|claude) install_for "$t" ;;
    *) install_tool "$t" ;;
  esac
done

# Shared cache for the app
mk "$AIROOT/$APP/tasks"; mk "$AIROOT/$APP/project"
for d in contracts templates project-overrides; do
  if [[ $DRY -eq 1 ]]; then echo "DRY: copy $d -> $AIROOT/$APP/"; else cp -R "$KIT/$d" "$AIROOT/$APP/"; fi
done
DF="$KIT/domains/$DOMAIN/DOMAIN.md"; [[ -f "$DF" ]] || DF="$KIT/domains/_template/DOMAIN.md"
write "$AIROOT/$APP/DOMAIN.md" < "$DF"
echo "Done ($TARGET, $SCOPE). Cursor: @captain build-feature <TASK-KEY>. Claude Code: /build-feature <TASK-KEY>"
for t in $TARGETS; do case "$t" in
  codex) echo "Codex: \$build-feature <TASK-KEY> (skill), bots are custom agents (ask Codex to use captain)." ;;
  antigravity) echo "Antigravity: pick captain in /agents, then /build-feature <TASK-KEY> (skill)." ;;
  gemini) echo "Gemini CLI: /build-feature <TASK-KEY>, or @captain <task>." ;;
  windsurf) echo "Windsurf: /build-feature <TASK-KEY> (workflow), @captain for the Captain skill." ;;
  copilot) echo "Copilot: pick the captain agent, then /build-feature <TASK-KEY> (prompt file)." ;;
  grok) echo "Grok Build: /build-feature <TASK-KEY> (skill), bots in /agents." ;;
  generic) echo "Other agents: point the agent at AGENTS.md and ask it to act as captain (.agents/bots/captain.md)." ;;
esac; done
