# Multi-case coherence

## Principle

Branch on **data/state**, not by cloning entire flows per case.

## Good

- One UseCase + parameters / result type variants
- One immutable state with status enum covering loading/success/error/empty
- Shared widgets driven by payload

## Bad

- Copy-paste controllers/views per similar case
- Divergent mock vs live business rules
- Happy-path-only with silent catch

## Minimum case matrix

| Case | Expect |
|------|--------|
| Happy | Success state + correct navigation/UI |
| Invalid input | Validation message; no crash |
| Empty data | Empty UI; no null crash |
| Auth required | Login wall / blocked action |
| Network / AppError | `_errorState` + user message |
| Mock on | Isolated mock payloads; same UX contract |
