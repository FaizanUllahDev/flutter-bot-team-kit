# Install

The kit has one tool-neutral source (`agents/`, `skills/`, `AGENTS.md`) and two adapters (`.cursor/`, `.claude/`).

## Option A: installer (recommended)
```bash
bash install/install.sh --dry-run   # preview, writes nothing
bash install/install.sh
```
It asks: target (cursor / claude / both), scope (global / project), owner, app, domain, stack, fvm, tracker, who handles git, AI-ROOT, Cursor strong model, and each optional bot.

Git mode: `--git=self` (default, bots never commit, push, rebase or tag) or `--git=bots` (only flutter-dev and git-advisor may run git, after your OK per action; no force-push, `reset --hard` or history rewrites; `.claude/settings.json` keeps `git *` under ask). Repo auth (SSH keys, tokens, GitHub login) always stays with you. The repo source stays in `self` mode; only installed files change.

| Target + scope | Writes to |
|---|---|
| cursor, global | `~/.cursor/agents/`, `~/.cursor/skills/` |
| cursor, project | `<REPO>/.cursor/agents/`, `<REPO>/.cursor/skills/`, `<REPO>/.cursor/rules/team.mdc` |
| claude, global | `~/.claude/agents/`, `~/.claude/skills/`, `~/.claude/commands/`, `~/.claude/team-AGENTS.md` |
| claude, project | `<REPO>/.claude/{agents,skills,commands}/`, `<REPO>/AGENTS.md`, `<REPO>/CLAUDE.md`, `<REPO>/.claude/settings.json` |
| any | `<AI-ROOT>/<App-Name>/` (contracts, templates, project-overrides, DOMAIN.md) |

Model mapping from `tier:`:
| Tier | Cursor | Claude Code |
|---|---|---|
| default | `auto` | `inherit` |
| strong (gap-finder, dev-planner) | your model name (or `auto`) | `opus` |

## Option B: manual, Cursor
1. Copy `.cursor/agents/*.md` (core + wanted optional) to `~/.cursor/agents/`.
2. Copy each `skills/<group>/<name>/` to `~/.cursor/skills/<name>/`.
3. Copy `.cursor/rules/team.mdc` to `<REPO>/.cursor/rules/`.
4. Replace `<AI-ROOT>`, `<App-Name>`, `<REPO>`, `<JIRA-KEY>`.

## Option C: manual, Claude Code
1. Copy `.claude/agents/*.md` to `~/.claude/agents/` or `<REPO>/.claude/agents/`.
2. Copy each `skills/<group>/<name>/` to `~/.claude/skills/<name>/`.
3. Copy `.claude/commands/*.md` to `<REPO>/.claude/commands/`.
4. Copy `AGENTS.md` and `CLAUDE.md` to the repo root (`CLAUDE.md` contains `@AGENTS.md`).
5. Copy `.claude/settings.example.json` to `<REPO>/.claude/settings.json` and adjust.

## Option D: Grok Bot teams
1. Load the `getting-started` skill and answer `install/setup-questions.md`.
2. Load `team-builder` to create one bot per chosen agent file.
3. Give each bot its `agents/*.md` text and `AGENTS.md`.

## Regenerate adapters
After editing `agents/` or `AGENTS.md`:
```bash
bash install/gen-adapters.sh
```

## Uninstall
Delete the copied files. Nothing else is changed.
