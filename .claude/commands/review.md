---
description: Review the current diff (quality, security, rebuilds, Codacy-style rules)
argument-hint: [path or scope]
---
Review the current changes $ARGUMENTS using pr-reviewer and codacy-checker.
- Rules: templates/codacy-rules.md, templates/quality-must-haves.md.
- Output review.md and codacy.md per contracts/. Failures only, then "All other checks PASS".
- Do not edit code; list fixes for my OK.
