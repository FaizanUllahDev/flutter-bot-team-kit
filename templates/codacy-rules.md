# Local Codacy-style rules
| Rule | OK | Fail |
|---|---|---|
| Cyclomatic complexity | <= 8 | > 15 |
| Method length | <= 50 lines (build <= 60) | above |
| File length | <= 500 lines | above |
| Nesting depth | < 5 | >= 5 |
| Parameters | <= 7 | > 7 |
| Duplicated blocks | none of 6+ lines | any |
| Diff coverage | >= 80% | below |
Grade A-F. Gate: B or above. Local rules only; no CLI, no network.
