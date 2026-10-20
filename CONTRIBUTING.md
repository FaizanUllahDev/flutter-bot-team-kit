# Contributing

Thanks for helping. Keep changes small, generic and easy to review.

## Ground rules
- Generic only: no real app, company, people, ticket keys, paths, devices or secrets. Use `<AI-ROOT>`, `<App-Name>`, `<REPO>`, `<JIRA-KEY>`.
- English, short bullets and tables. No em-dashes.
- Safety rules in `AGENTS.md` cannot be weakened.

## How to contribute
1. Fork and create a branch (`feat/<short-name>` or `fix/<short-name>`).
2. Make your change.
3. Run the checks below.
4. Open a PR using the template.

## Checks before a PR
```bash
bash -n install/install.sh
bash install/install.sh --dry-run < /dev/null
rg -n $'\u2014' .      # em-dash check, must be empty
```
If you change an example page or the QA template, re-render its PNG in `docs/images/` (headless Chrome, 2x, under 1 MB).

## Adding a bot
- Add `agents/core/<name>.md` or `agents/optional/<name>.md` with `name`, `description`, `tier: default|strong` frontmatter (no tool-specific fields).
- Run `bash install/gen-adapters.sh` to refresh `.cursor/` and `.claude/` adapters.
- Define input, output (a `contracts/` file) and stage.
- Add a row to the Bots table in README.md.

## Adding a skill
- Add `skills/<group>/<name>/SKILL.md` with `name` and `description` frontmatter.
- Add a row to the Skills table.
