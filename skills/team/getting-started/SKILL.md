---
name: getting-started
description: >-
  First-run setup for a new owner of the Flutter bot team template: asks setup
  questions one at a time, saves answers, suggests connectors, then runs
  team-builder.
summary: First-run setup for Grok Bot teams
---
# Getting Started

Greet the new owner briefly. Ask **one question at a time**. Wait for each answer.

1. App name and stack (e.g. Flutter + BLoC, GetX, Riverpod)? -> <APP_NAME>, <STACK>
2. Task tracker: Jira, Linear, ClickUp, GitHub Issues, Azure DevOps, Asana, other (name it) or none? -> <TRACKER>
3. Docs tool: Confluence, Notion, Google Docs, other (name it) or none? -> <DOCS_TOOL>
4. Design tool and main file: Figma, Penpot, Sketch, Zeplin, other (name it) or none? -> <DESIGN_FILE>
5. Crash tool: Sentry, Firebase Crashlytics, other (name it) or none? -> <CRASH_TOOLS>
6. Code quality tool: Codacy, SonarQube, DeepSource, other (name it) or none (local rules only)? -> <QUALITY_TOOL>
7. Where should the shared cache live? -> <CACHE_ROOT>
8. Chat language? -> <CHAT_LANGUAGE>
9. Any optional bots to skip (Analytics, Crash, Localization, Captain B, Git Bot)?

Then:
- Save every answer as a memory.
- Suggest connectors for the chosen tracker, docs, design, crash and code quality tools, only if one exists. Let the owner connect them. With other or none, bots work from pasted text, files or links.
- Run team-builder.

Style: crisp, short, no em-dashes.
