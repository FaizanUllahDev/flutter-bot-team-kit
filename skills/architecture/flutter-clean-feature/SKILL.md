---
name: flutter-clean-feature
description: >-
  Scaffolds a new Flutter feature module using Strict Nested Clean Architecture
  and GetX lean MVVM (data/domain/presentation, bindings, immutable state,
  verb+noun UseCases, mock payloads). Use when creating a new feature under
  lib/**/features/, adding a Clean module, or when the user asks for feature
  scaffold / feature workflow.
summary: New Clean features (data/domain/presentation)
---

# Flutter Clean Feature Scaffold

## Before coding

1. Read project `CURSOR.md` (preferred) or `AGENTS.md` / `.cursor/rules` for concrete names (API, palette, mock flag, error catcher).
2. **Captain cache (when present):** read `.cursor/cache/arch_signature.json`, `bdd_matrix.json`, `api_minified.json`, `figma_state.json`, do not re-read raw BRS/Jira/OpenAPI.
3. Confirm feature folder name and whether auth gate is required.
4. Prefer `fvm flutter` when available.
5. **Mock:** honor captain `MOCK_ENABLED` (or project alias documented in `CURSOR.md`, e.g. a global mock testing flag) in NetworkService → `mock_config` when true.

## Create in order

```
lib/<...>/features/<feature>/
  data/models/
  data/mock_config/
  data/services/
  domain/usecases/
  presentation/state/
  presentation/controllers/
  presentation/bindings/
  presentation/views/
  presentation/widgets/
test/<...>/features/<feature>/   # mirror
```

### Multi-module features

One nest only. Submodules = folders + file prefixes inside each layer. One Binding from app startup; screens use `*_view` / `*View` and `Get.find`.

## Network layer (required)

- Prefer the project's **shared network helper** named in `CURSOR.md` / `arch_signature` (pass data + URL + parse only).
- Helper owns encode/encrypt + HTTP client + Completer.
- Do **not** invent new legacy API-manager entrypoints; existing legacy call sites may remain.
- Feature NetworkService: respect `MOCK_ENABLED` (or project alias) → mock_config; else call shared helper.
- Heavy JSON/crypto: isolate / project off-main helpers only after profiling.
- Cover BDD scenario ids from `bdd_matrix.json` in tests (hand off to `unit-test-engineer` under captain).

## Implementation checklist
- [ ] Errors: throw AppError from service/usecase; controller _errorState + the central error handler (never null/silent failure)

- [ ] Network service owns encode/decode + endpoint; Do not extend ApiManager; call shared helper / NetworkManager / FeatureNetworkCaller only
- [ ] Network service respects global mock flag → mock_config payloads
- [ ] UseCases named verb+noun (`FetchXUseCase`); orchestrate cache vs network
- [ ] Immutable state + status enum; single `Rx<State>`
- [ ] Controller: `try/catch` → `_errorState` via project error catcher; `ever` for side effects
- [ ] Binding: Service → UseCase → Controller with `Get.lazyPut(..., fenix: true)`
- [ ] Views dumb + `Obx`; localization keys; global theme; no `print()`
- [ ] Mirrored tests; mock at UseCase/service constructor boundary
- [ ] Native folders untouched unless user approved specific files

## Templates

See [templates.md](templates.md) for generic skeletons, replace placeholders with project types.
