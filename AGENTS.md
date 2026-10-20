# Core team rules

## Flow
- Pipeline: Intake > Gap > Plan > Dev+Tests > Analyze > Review > QA > Report > Tracker.
- Approval gate after every stage. Stop and wait for the owner's OK.
- Answer-only: if the owner's message ends with "?" or asks for a suggestion, only answer. No work, no rule changes. Then ask whether to add it to the rules.

## Handoff and tokens
- Each stage writes one summary file in `<AI-ROOT>/<App-Name>/tasks/<JIRA-KEY>/` using `contracts/`.
- Next bot reads only that summary. Intake bots read raw sources once.
- Read code signatures, not full files. Surgical diffs only. Reports list failures plus one "All other PASS" line.

## Quality
- Light TDD: write scenario tests with or right after the code. Devs may add tests for helpers missing from the plan.
- Diff coverage 80%+. Codacy-style grade B or above (`templates/codacy-rules.md`).
- Analyzer gate: `fvm flutter analyze` and `fvm flutter test` if fvm is used, else `flutter analyze` / `flutter test`. Zero new issues.

## Safety (always wins)
- Never commit, push, rebase or tag. The owner does all git.
- Never read or output secrets or credentials.
- No native `android/` / `ios/` edits without file-specific approval.
- Test accounts stay in `project/test-accounts.md` locally only. Wrong PIN only once per number. No PIN in screenshots.
- No tracker posts or status changes without approval.
- Never remove required analytics/log events.

## Priority
1. Safety rules above.
2. Project's own agents, skills and rules (`project-overrides/`, repo `.cursor/`).
3. This kit's defaults.

## Rule sync
- Every rule change goes to `cache-keeper`, which updates all rule files at once.
