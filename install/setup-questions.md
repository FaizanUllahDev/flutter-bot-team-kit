# Setup questions (asked by the Captain or install.sh)

| # | Question | Options | Used for |
|---|---|---|---|
| 1 | Your name (the owner) | text | Approvals |
| 2 | App name(s) | text, comma list | `<App-Name>` |
| 3 | Domain | fintech / telecom / other | `domains/` file |
| 4 | State management | GetX / Bloc / Riverpod / other | Skills defaults |
| 5 | Architecture | clean / legacy / mixed | Which skills load |
| 6 | Use fvm? | yes / no | Analyzer command |
| 7 | Tracker | Jira / Linear / ClickUp / GitHub Issues / Azure DevOps / Asana / other (name it) / none (default Jira) | Tracker bots, `<TASK-KEY>` format (`install.sh --tracker=`) |
| 8 | Design source | Figma / Penpot / Sketch / Zeplin / other (name it) / any / none (default any) | design-analyst (`--design=`) |
| 9 | Docs source | Confluence / Notion / Google Docs / other (name it) / any / none (default any) | brs-analyst source (`--docs=`) |
| 10 | Crash tool | Sentry / Firebase Crashlytics / other (name it) / none (default none) | crash and analytics analysts (`--crash=`) |
| 11 | Code quality tool | Codacy / SonarQube / DeepSource / other (name it) / none (default none, local rules only) | quality-checker wording; thresholds stay in `templates/quality-rules.md` (`--quality=`) |
| 12 | QA tools wanted | UI flow runner, image diff, proxy, API mocks, none | qa-lead |
| 13 | Optional bots | toggle each | `agents/optional/` |
| 14 | Chat language | e.g. English | Bot replies (files stay English) |
| 15 | AI-ROOT path | folder path | `<AI-ROOT>` |
| 16 | Model routing | default / strong tier (Claude Code: inherit / opus, Cursor: auto / model name, Antigravity: inherit / pro, Codex: high reasoning; other tools use the session model) | adapters |
| 17 | Target tool(s) | cursor / claude / codex / antigravity / gemini / windsurf / copilot / grok / generic, a comma list, `both` (cursor + claude) or `all` | install.sh (`--target=<list>`) |
| 18 | Scope | global / project | install.sh |
| 19 | Who handles git? | 1) I do git myself (default) / 2) Let bots run git (you confirm each commit/push; repo auth stays with you) | Git rule in AGENTS.md and team rules, flutter-dev + git-advisor text, `.claude/settings.json` denies (`install.sh --git=self\|bots`) |
