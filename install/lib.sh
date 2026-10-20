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
