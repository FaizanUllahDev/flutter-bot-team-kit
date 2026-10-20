---
name: feature-module-standard
description: >-
  Standard single-nest feature layout (one data/domain/presentation per feature,
  one binding registered at app start, *_view screens, file-prefix modules).
  Use with flutter-clean-feature when building or reshaping a feature folder.
---

# Feature module standard

**Reference feature:** set your best existing feature in `project-overrides/<App-Name>.md`.

## Stack

- Example uses GetX. For Bloc or Riverpod, map Binding to your DI and Controller to Cubit/Notifier.
- Prefer `fvm flutter` when `.fvmrc` exists.

## Folder layout (one feature = one nest)

Do not nest sub-features with their own data/domain/presentation. Use file-name prefixes for modules.

```
lib/<features-root>/<feature>/
  data/        models/<module>/  mock_config/<module>/  services/<module>/
  domain/      usecases/<module>/  utils/  policies/
  presentation/
    bindings/              # ONE binding per feature
    controllers/<module>/
    state/<module>/
    views/<module>/        # screens: *_view.dart / class *View
    widgets/<module>/
```

Mirror tests under `test/` with the same subfolders. Put code used by 2+ modules in `shared/`.

## Rules

- One feature binding, registered once at app start, not from each view.
- Screens only look up controllers; no binding calls inside widgets.
- Views read state and call intents only.
- One immutable state object + status enum over competing bools.
- Controllers: try/catch, route errors to the project's central error handler.
- Controllers call UseCases; UseCases call services. UseCase names are verb + noun (`GetItemsUseCase`).
- Use project text styles, tap wrappers and semantics helpers.
- Localization keys only; no hardcoded UI strings.
- Shared cross-feature UI goes to the project's common widgets folder.
- One state-management library per repo. No `print()`; use the project logger.

## Scaffold checklist

- [ ] Single data/domain/presentation under the feature
- [ ] One binding registered at app start
- [ ] Screens named `*_view.dart`
- [ ] Modules clear via file prefixes
- [ ] Immutable state if multi-step
- [ ] Localization keys wired
- [ ] Semantics on interactive controls
- [ ] Mirrored tests; analyze touched paths
