# Setup questions (asked by the Captain or install.sh)

| # | Question | Options | Used for |
|---|---|---|---|
| 1 | Your name (the owner) | text | Approvals |
| 2 | App name(s) | text, comma list | `<App-Name>` |
| 3 | Domain | fintech / telecom / other | `domains/` file |
| 4 | State management | GetX / Bloc / Riverpod / other | Skills defaults |
| 5 | Architecture | clean / legacy / mixed | Which skills load |
| 6 | Use fvm? | yes / no | Analyzer command |
| 7 | Tracker | Jira / Linear / none | Tracker bots, `<JIRA-KEY>` format |
| 8 | Design tool | Figma yes / no | design-analyst |
| 9 | Docs | Confluence / none | brs-analyst source |
| 10 | Crash tool | Sentry / Firebase / none | crash/firebase analysts |
| 11 | QA tools wanted | UI flow runner, image diff, proxy, API mocks, none | qa-lead |
| 12 | Optional bots | toggle each | `agents/optional/` |
| 13 | Chat language | e.g. English | Bot replies (files stay English) |
| 14 | AI-ROOT path | folder path | `<AI-ROOT>` |
| 15 | Model routing | default / strong tier (Claude: inherit / opus, Cursor: auto / model name) | adapters |
| 16 | Target tool | cursor / claude / both | install.sh |
| 17 | Scope | global / project | install.sh |
| 18 | Who handles git? | 1) I do git myself (default) / 2) Let bots run git (you confirm each commit/push; repo auth stays with you) | Git rule in AGENTS.md and team rules, flutter-dev + git-advisor text, `.claude/settings.json` denies (`install.sh --git=self\|bots`) |
