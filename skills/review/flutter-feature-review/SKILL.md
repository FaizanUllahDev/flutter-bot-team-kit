---
name: flutter-feature-review
description: >-
  Reviews Flutter diffs against Strict Nested Clean Architecture, GetX lean
  MVVM, legacy-safety, secrets/native boundaries, UI/themings, and test
  conventions. Use when reviewing a PR, feature diff, or after scaffolding a
  module.
summary: Review checklist
---

# Flutter Feature / Diff Review

## Process

1. Identify modern vs legacy paths in the diff.
2. Review only what changed; do not demand unrelated refactors.
3. Report findings as:

```
- Critical: <file:area>, problem, fix
- Warning: <file:area>, problem, fix
- Nice: <file:area>, suggestion
```

## Modern checklist

- [ ] Nested under `features/<feature>/{data,domain,presentation}`
- [ ] UseCase verb+noun naming
- [ ] Mock flag + mock_config on network paths
- [ ] Single immutable state + status enum
- [ ] Controller `_errorState` + no direct DB/network orchestration when UseCases exist
- [ ] Failures throw `AppError` (with message); not swallowed as null / silent feature `.failure()`
- [ ] Binding order + fenix as project standard
- [ ] Views dumb; localization; project global palette / theme tokens (`CURSOR.md`); no `print()`
- [ ] New UI uses `ScaleHelper.sp/w/h/r` (no sizer import); design fonts scaled
- [ ] Tests mirrored; assertions on state

## Legacy checklist

- [ ] No silent modernization
- [ ] Business logic preserved unless change is the bugfix
- [ ] No new state-management libraries

## Captain / architecture

- [ ] Diff matches `.cursor/cache/arch_signature.json` (no invented stack)
- [ ] Silent Redesign: new styles on existing common widgets escalated / confirmed, not silently forked
- [ ] `MOCK_ENABLED` (or project alias) honored on network paths when captain cache was used
- [ ] BDD scenarios from `bdd_matrix.json` covered or explicitly deferred to `unit-test-engineer`

## Always

- [ ] No secrets committed or printed
- [ ] No native edits without documented user consent
