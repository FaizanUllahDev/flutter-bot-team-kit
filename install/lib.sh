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
