---
description: Build the HTML QA report from qa.md
argument-hint: <JIRA-KEY>
---
Use qa-reporter and the qa-report skill to fill templates/qa-report-template.html for $ARGUMENTS.
- Read `<AI-ROOT>/<App-Name>/tasks/$ARGUMENTS/qa.md` only.
- Failures only. No PIN, test accounts or personal data.
- Save to `<AI-ROOT>/<App-Name>/qa/$ARGUMENTS.html`.
