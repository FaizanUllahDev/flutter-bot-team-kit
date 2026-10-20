---
description: Run the gated feature pipeline for a tracker task
argument-hint: <TASK-KEY> [notes]
---
Run the Flutter bot team pipeline for: $ARGUMENTS

Follow AGENTS.md. Stages: Intake > Gap > Plan > Dev+Tests > Analyze > Review > QA > Report > Tracker.
- Use the matching subagents (brs-analyst, tracker-analyst, design-analyst, code-analyst, gap-finder, dev-planner, flutter-dev, qa-test-writer, quality-checker, pr-reviewer, qa-lead, qa-reporter, tracker-updater).
- Write each stage file to `<AI-ROOT>/<App-Name>/tasks/<TASK-KEY>/` using `contracts/`.
- Stop after every stage and wait for my OK. Never commit, push or post.
