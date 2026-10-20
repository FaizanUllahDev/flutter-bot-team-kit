---
name: flutter-legacy-edit
description: >-
  Safely edits legacy Flutter fat controllers and widgets without modernizing
  architecture. Use when working under lib/**/controllers/, lib/ui/widgets/,
  fixing bugs in old domains, or when the user says preserve legacy / do not
  refactor architecture.
summary: Safe edits in legacy code
---

# Flutter Legacy Safe Edit

## Mindset

Surgical fix. Same architecture in, same architecture out.

## Steps

1. Confirm path is legacy (`controllers/`, non-feature `widgets/`, old `models/`).
2. Map callers of any public API you will change.
3. Implement the smallest fix that satisfies the request.
4. Apply global hygiene only on touched lines: no `print()`, localization keys, project logger, palette.
5. Do **not** create Clean feature folders, UseCases, or new Bindings unless asked.
6. If a modern feature needs this code, bridge via existing controller methods.

## Stop and ask

- Fix requires renaming widely used APIs
- Fix requires native `android/` / `ios/` changes
- User request is ambiguous between "fix bug" vs "migrate to features/"

## Output

Briefly state: what stayed legacy, what changed, and any follow-up migration suggestion (do not implement migration unless asked).
