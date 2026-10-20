---
name: flutter-reusable-widget
description: >-
  Designs payload-driven reusable Flutter common widgets (review/confirm/success
  screens, sheets) that adapt via data + callbacks so one file can be reused
  across flows or copied to another project. Use when building a generic review
  screen, confirmation UI, shared chrome, or when the user wants one widget +
  payload instead of per-flow screens.
summary: Flow-agnostic shared widgets
---

# Flutter Reusable Common Widget

## Goal

Ship a **flow-agnostic** widget: callers pass a **payload** + **callbacks**.  
No GetX controller inside the widget. Same widget powers flow A, flow B, flow C, etc.

**Examples (see feature-module-standard skill):** prefer the shared UI folder from `CURSOR.md` / `arch_signature`.

## Silent Redesign (captain)

If Figma introduces a **new style for an existing common widget** already in the codebase, do **not** silently fork a second common implementation. Escalate to `gap-matrix-engine` / captain Silent Redesign user gate first.

## Decision: common vs feature widget

| Put in `utils/widgets/common/` (or project shared UI) | Keep in feature `presentation/widgets/` |
|------------------------------------------------------|----------------------------------------|
| Same layout used by 2+ flows | One-off chrome |
| Configured only by data + callbacks | Needs feature domain types |
| Safe to copy to another app with light renames | Tightly coupled to one API |

If unsure → design as common + payload first.

## Portable unit (prefer one file)

For maximum reuse / new-project copy, prefer **one Dart file** containing:

1. Immutable payload / row / note / semantics config classes  
2. The `StatelessWidget` / `StatefulWidget`  
3. Optional tiny private sub-widgets in the same file  

Split to a second `*_payload.dart` only when the file exceeds ~300 lines or multiple widgets share the payload.

Feature-specific **mappers** stay in the feature (`*_mapper.dart`), they build the payload from domain models. Do **not** put mappers in the common file.

## Contract (required)

```dart
/// Pure UI. Driven by [ReviewScreenPayload]. No controllers. No Get.find.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    required this.payload,
    required this.onPrimary,
    this.onSecondary,
    this.onBack,
    super.key,
  });

  final ReviewScreenPayload payload;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final VoidCallback? onBack;
}
```

### Payload rules

- Immutable (`const` constructors), plain fields, `copyWith` only if useful
- **Already-resolved UI strings** (translated), do not call `.tr` inside common widget unless the project standard requires keys; prefer strings so the file ports easily
- Lists of rows/sections for variable content (`List<DetailRow>`)
- Optional blocks via `null` / empty / `bool showX`, never fork separate widgets per flow
- Loading / enabled flags on payload (`isSubmitting`, `canSubmit`), parent owns Rx and passes current values
- Optional semantics ids/labels on payload for tests

### Widget rules

- **No** `Get.find`, **no** UseCases, **no** feature imports, **no** API calls
- Theme via project global palette / `Theme.of(context)`, never hardcode flow-specific palettes inside common if avoidable; accept colors/paths in payload when chrome differs
- Interaction via constructor callbacks only
- Hide sections when data absent (empty string / null / false)
- Accessibility: `AppSemantics` / Semantics on interactive nodes; ids from payload when provided
- Logging: project logger only if needed; never `print()`

## Workflow

1. Ask which flows will reuse it and which sections vary.
2. Sketch payload fields (title, rows, CTAs, flags, optional media paths).
3. Implement payload + widget (one file preferred).
4. Add/adjust a **feature mapper** that maps domain → payload (per flow).
5. Wire parent: build payload from state, pass callbacks that call controller intents.
6. Smoke-check: two different payloads render correctly without widget edits.

## Anti-patterns

- Copy-paste of nearly identical review screens per feature
- Embedding feature or domain models inside the common widget
- Reading controllers or global user stores for business decisions inside the widget (pass via payload)
- Feature-specific hex palettes baked into common UI without payload override
- Boolean explosion (`isFlowA`, `isFlowB`), use data shape + optional sections instead

## Checklist

- [ ] Payload is pure data; widget is dumb
- [ ] 2+ flows can use it by changing payload only
- [ ] Callbacks for all user actions
- [ ] Optional sections gated by null/empty/flags
- [ ] No feature/domain imports in common file
- [ ] Localization / theme follow project globals or payload strings
- [ ] Mapper lives in feature layer
- [ ] Documented constructor + example payload in dartdoc

## Templates

See [templates.md](templates.md).
