---
name: qa-report
description: Fill templates/qa-report-template.html from qa.md (scorecard, failures only, devices array, section toggles, PDF button).
---
# QA report
1. Copy the template to `<AI-ROOT>/<App-Name>/qa/<JIRA-KEY>.html`.
2. Edit only the JSON config block. Replace every EXAMPLE value.
3. Sections (toggle in `sections`, choices saved in the browser):
   - Overview, **Executive scorecard**, Summary, Pixel grade, Translations, Device matrix, Test cases, Error flows, Failures, **UI performance by screen**, Performance (all devices), API latency, Video, Sign-off.
4. Executive scorecard (`scorecard`): 4 cards (app performance, UI performance, API and integration, functionality).
   - Each card: `score` 0-100, or `null` to auto-average `inputs[].sub` (100 met, 70 near, 40 missed).
   - Grade A 90+, B 80+, C 70+, D 60+, E 50+, F below 50. Status pass 80+, warn 60-79, fail below 60.
   - Overall = weighted average (`weights`), or set `overall.score`.
5. UI performance (`uiPerf`): list only failing or warn screen x device rows (FPS, janky %, first render ms, rebuilds, optional image cache hit). Set `totalScreens`; the report adds "All remaining N screens PASS".
6. Performance: one `perDevice` row per tested device; overall score = average unless `overallScore` is set. Spec card shows the lowest-spec device.
7. Pixel: list minor/major only. Translations: failing keys only.
8. No PIN, test accounts or personal data in screenshots.
