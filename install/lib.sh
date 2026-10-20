#!/usr/bin/env bash
# Shared adapter helpers. Source of truth: agents/, skills/, AGENTS.md (tool-neutral).

# emit_agent <src.md> <cursor|claude> <strong-model-for-cursor>
# Prints the agent with tool-specific frontmatter.
emit_agent() {
  local src="$1" tool="$2" strong="${3:-auto}" name desc tier model tools=""
  name=$(sed -n 's/^name: //p' "$src" | head -1)
  desc=$(sed -n 's/^description: //p' "$src" | head -1)
  tier=$(sed -n 's/^tier: //p' "$src" | head -1)
  if [[ "$tool" == claude ]]; then
    if [[ "$tier" == strong ]]; then model=opus; else model=inherit; fi
    [[ "$name" == git-advisor ]] && tools="tools: Read, Grep, Glob"
  else
    if [[ "$tier" == strong ]]; then model="$strong"; else model=auto; fi
  fi
  printf -- "---\nname: %s\ndescription: \"%s\"\n" "$name" "${desc//\"/\\\"}"
  [[ -n "$tools" ]] && printf "%s\n" "$tools"
  printf "model: %s\n---\n" "$model"
  awk 'BEGIN{c=0} /^---$/ && c<2 {c++; next} c>=2' "$src"
}

# emit_cursor_rule <AGENTS.md>
emit_cursor_rule() {
  printf -- "---\ndescription: Flutter bot team core rules\nglobs: \"**/*\"\nalwaysApply: true\n---\n"
  cat "$1"
}

# Git mode filters (install time only; the repo source stays in safe "self" mode).
# GIT_MODE=self keeps text unchanged. GIT_MODE=bots switches the git rules to opt-in.
GIT_MODE="${GIT_MODE:-self}"

# git_rules: AGENTS.md, team rules and Claude commands (stdin > stdout)
git_rules() {
  if [[ "$GIT_MODE" != bots ]]; then cat; return; fi
  sed -e 's#^- Never commit, push, rebase or tag\. The owner does all git\.$#- Git (opt-in): only flutter-dev and git-advisor may run git, and only after explicit OK from the owner for each action (commit, push, rebase, tag). Never ask for, read or store credentials (SSH keys, tokens, logins). Never force-push, `git reset --hard` or rewrite pushed history.#' \
      -e 's#Never commit, push or post\.#No git without my explicit OK for each action. Never post.#' \
      -e 's#Stop for my OK\. No git\.#Stop for my OK. No git without my explicit OK for each action.#'
}

# git_agent <name>: agent text (stdin > stdout); only flutter-dev and git-advisor change
git_agent() {
  if [[ "$GIT_MODE" != bots || ( "$1" != flutter-dev && "$1" != git-advisor ) ]]; then cat; return; fi
  sed -e 's#^- Never commit, push, post to the tracker, or read secrets\.$#- Run git (commit, push, rebase, tag) only after explicit OK from the owner for each action; never handle credentials, force-push, `git reset --hard` or rewrite pushed history. Never post to the tracker or read secrets.#' \
      -e 's#; never runs git#; runs git only after explicit OK from the owner#g'
}

# git_settings: .claude/settings.json (stdin > stdout); git stays under "ask", force-push and reset --hard stay denied
git_settings() {
  if [[ "$GIT_MODE" != bots ]]; then cat; return; fi
  sed -e 's#"Bash(git commit \*)"#"Bash(git push --force *)"#' \
      -e 's#"Bash(git push \*)"#"Bash(git push -f *)"#' \
      -e '/"Bash(git rebase \*)",/d' \
      -e '/"Bash(git tag \*)",/d'
}

# ---------------------------------------------------------------------------
# Multi-tool emitters (installer only). All read the tool-neutral source:
# agents/*/*.md, skills/, AGENTS.md and .claude/commands/*.md (command source).
# ---------------------------------------------------------------------------

# fm_get <file> <key>: first frontmatter value for key
fm_get() {
  awk -v k="$2" 'NR==1 && /^---$/ {f=1; next} f && /^---$/ {exit} f && index($0, k": ")==1 {print substr($0, length(k)+3); exit}' "$1"
}
# md_body <file>: content after the frontmatter block
md_body() { awk 'BEGIN{c=0} /^---$/ && c<2 {c++; next} c>=2' "$1"; }
# yq <text>: YAML/TOML double-quoted string
yq() { local s="${1//\\/\\\\}"; printf '"%s"' "${s//\"/\\\"}"; }

# emit_agent_tool <antigravity|gemini|copilot|grok|generic> <src.md>
emit_agent_tool() {
  local tool="$1" src="$2" name desc tier
  name=$(fm_get "$src" name); desc=$(fm_get "$src" description); tier=$(fm_get "$src" tier)
  case "$tool" in
    generic) cat "$src"; return ;;
    antigravity)
      local model=inherit main=false
      [[ "$tier" == strong ]] && model=pro
      [[ "$name" == captain || "$name" == captain-b ]] && main=true
      printf -- "---\nname: %s\ndescription: %s\nmodel: %s\nsubagent: true\nmainAgent: %s\n---\n" "$name" "$(yq "$desc")" "$model" "$main" ;;
    gemini)  printf -- "---\nname: %s\ndescription: %s\nkind: local\n---\n" "$name" "$(yq "$desc")" ;;
    copilot) printf -- "---\nname: %s\ndescription: %s\n---\n" "$name" "$(yq "$desc")" ;;
    grok)    printf -- "---\nname: %s\ndescription: %s\nmodel: inherit\n---\n" "$name" "$(yq "$desc")" ;;
  esac
  md_body "$src"
}

# emit_agent_codex <src.md>: Codex custom agent (TOML)
emit_agent_codex() {
  local src="$1" name desc tier
  name=$(fm_get "$src" name); desc=$(fm_get "$src" description); tier=$(fm_get "$src" tier)
  printf 'name = %s\ndescription = %s\n' "$(yq "$name")" "$(yq "$desc")"
  [[ "$tier" == strong ]] && printf 'model_reasoning_effort = "high"\n'
  printf "developer_instructions = '''\n"; md_body "$src"; printf "'''\n"
}

# emit_agent_skill <src.md>: bot as an Agent Skill (tools without custom subagents)
emit_agent_skill() {
  local src="$1" name desc
  name=$(fm_get "$src" name); desc=$(fm_get "$src" description)
  printf -- "---\nname: %s\ndescription: %s\n---\n" "$name" "$(yq "Flutter bot team role $name. $desc Use when the Captain or the owner hands work to $name.")"
  md_body "$src"
}

# Commands (source: .claude/commands/<name>.md with $ARGUMENTS)
cmd_text() { md_body "$1" | sed "s#\\\$ARGUMENTS#$2#g"; }

# emit_cmd_gemini <cmd.md>: Gemini CLI custom command (TOML)
emit_cmd_gemini() {
  printf 'description = %s\nprompt = '"'''"'\n' "$(yq "$(fm_get "$1" description)")"
  cmd_text "$1" '{{args}}'; printf "'''\n"
}
# emit_cmd_windsurf <cmd.md>: Windsurf workflow
emit_cmd_windsurf() {
  printf -- "---\ndescription: %s\n---\n" "$(yq "$(fm_get "$1" description)")"
  cmd_text "$1" '<input>'; printf '\n`<input>` is the text you type after the command (%s).\n' "$(fm_get "$1" argument-hint)"
}
# emit_cmd_copilot <cmd.md>: Copilot prompt file
emit_cmd_copilot() {
  printf -- "---\ndescription: %s\nargument-hint: %s\nagent: agent\n---\n" "$(yq "$(fm_get "$1" description)")" "$(yq "$(fm_get "$1" argument-hint)")"
  cmd_text "$1" '${input:args}'
}
# emit_cmd_skill <cmd.md>: command as an Agent Skill (Codex, Antigravity, Grok slash skills)
emit_cmd_skill() {
  local n; n=$(basename "$1" .md)
  printf -- "---\nname: %s\ndescription: %s\nargument-hint: %s\n---\n" "$n" "$(yq "$(fm_get "$1" description). Use when the owner runs /$n or asks to $n.")" "$(yq "$(fm_get "$1" argument-hint)")"
  cmd_text "$1" '<input>'; printf '\n`<input>` is what the owner passed (%s).\n' "$(fm_get "$1" argument-hint)"
}
# emit_cmd_generic <cmd.md>: plain Markdown prompt
emit_cmd_generic() { printf '# /%s\n%s\n\n' "$(basename "$1" .md)" "$(fm_get "$1" description)"; cmd_text "$1" '<input>'; }

# emit_rule_antigravity <AGENTS.md stream on stdin>: modular global rule
emit_rule_antigravity() { printf -- "---\ntrigger: always_on\ndescription: Flutter bot team core rules\n---\n"; cat; }

# Safety configs. Mirror the safe denies from .claude/settings.example.json.
emit_codex_rules() {
  echo "# Flutter Bot Team Kit command rules (generated). Git mode: $GIT_MODE."
  echo "# Codex rules match command prefixes outside the sandbox; secret-file reads are covered by AGENTS.md."
  if [[ "$GIT_MODE" == bots ]]; then
    echo 'prefix_rule(pattern = ["git", "push", ["--force", "-f", "--force-with-lease"]], decision = "forbidden", justification = "Never force-push.")'
  else
    echo 'prefix_rule(pattern = ["git", ["commit", "push", "rebase", "tag"]], decision = "forbidden", justification = "The owner does all git.")'
  fi
  echo 'prefix_rule(pattern = ["git", "reset", "--hard"], decision = "forbidden", justification = "Never reset --hard.")'
  echo 'prefix_rule(pattern = ["git"], decision = "prompt", justification = "Ask the owner before any git command.")'
}

emit_grok_config() {
  local p
  echo "# Flutter Bot Team Kit permission rules (generated). Git mode: $GIT_MODE."
  echo "[permission]"
  echo "rules = ["
  for p in "**/.env" "**/.env.*" "**/env_key*.dart" "**/*.jks" "**/*.keystore" "**/*.p12" "**/key.properties" "**/GoogleService-Info.plist" "**/google-services.json" "**/test-accounts.md"; do
    echo "  { action = \"deny\", tool = \"read\", pattern = \"$p\" },"
  done
  echo '  { action = "deny", tool = "edit", pattern = "**/.env" },'
  if [[ "$GIT_MODE" == bots ]]; then
    echo '  { action = "deny", tool = "bash", pattern = "git push --force *" },'
    echo '  { action = "deny", tool = "bash", pattern = "git push -f *" },'
  else
    for p in "git commit *" "git push *" "git rebase *" "git tag *"; do echo "  { action = \"deny\", tool = \"bash\", pattern = \"$p\" },"; done
  fi
  echo '  { action = "deny", tool = "bash", pattern = "git reset --hard *" },'
  echo '  { action = "deny", tool = "bash", pattern = "cat *.env*" },'
  for p in "fvm flutter analyze *" "fvm flutter test *" "flutter analyze *" "flutter test *"; do echo "  { action = \"allow\", tool = \"bash\", pattern = \"$p\" },"; done
  echo "]"
}

emit_gemini_policy() {
  echo "# Flutter Bot Team Kit policy (generated). Git mode: $GIT_MODE."
  cat <<'TOML'
[[rule]]
toolName = ["read_file", "read_many_files"]
argsPattern = '(\.env|env_key[^"]*\.dart|\.jks|\.keystore|\.p12|key\.properties|GoogleService-Info\.plist|google-services\.json|test-accounts\.md)'
decision = "deny"
priority = 900
denyMessage = "Secrets and test accounts are off limits."

[[rule]]
toolName = ["write_file", "replace"]
argsPattern = '\.env'
decision = "deny"
priority = 900

[[rule]]
commandRegex = 'cat .*\.env'
decision = "deny"
priority = 900

[[rule]]
commandPrefix = "git reset --hard"
decision = "deny"
priority = 900

TOML
  if [[ "$GIT_MODE" == bots ]]; then
    printf '[[rule]]\ncommandRegex = %s\ndecision = "deny"\npriority = 900\ndenyMessage = "Never force-push."\n\n' "'git push.* (--force|-f)'"
  else
    printf '[[rule]]\ncommandRegex = %s\ndecision = "deny"\npriority = 900\ndenyMessage = "The owner does all git."\n\n' "'git (commit|push|rebase|tag)'"
  fi
  printf '[[rule]]\ncommandPrefix = "git"\ndecision = "ask_user"\npriority = 100\n'
}
