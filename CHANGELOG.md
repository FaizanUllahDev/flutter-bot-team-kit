# Changelog

## 1.0.0 (2026-10-20)
First public release.

- 9-stage gated pipeline: Intake, Gap, Plan, Dev + Tests, Analyze, Review, QA, Report, Tracker.
- 15 core bots + 7 optional, tool-neutral agent files (tier: default / strong).
- Cursor + Claude Code support with generated `.cursor/` and `.claude/` adapters, CLAUDE.md, slash commands and a safe settings example.
- Installer with target (cursor / claude / both) and scope (global / project).
- Multi-tool installer: `--target=` any of cursor, claude, codex, antigravity, gemini, windsurf, copilot, grok, generic (or `all`). Each tool gets native rules, bots (subagents, or skills where a tool has none), skills, the four commands and its deny-list file, all generated from one source.
- Tool-agnostic setup: the installer asks for your tracker (Jira, Linear, ClickUp, GitHub Issues, Azure DevOps, Asana, other or none), design source, docs source, crash tool and code quality tool (`--tracker=`, `--design=`, `--docs=`, `--crash=`, `--quality=`) and writes the names into the team rules. Bots use generic names: quality-checker (local code quality rules, `quality.md`), analytics-analyst (`analytics.md`) and the `<TASK-KEY>` placeholder.
- Skills, stage contracts, domain packs (fintech, telecom, template) and templates.
- QA report template: executive scorecard (4 scored cards + overall verdict), UI performance by screen, per-device quality scores, pixel check, translations, error flows and PDF export.
- Examples, section images and GitHub Pages landing page.
