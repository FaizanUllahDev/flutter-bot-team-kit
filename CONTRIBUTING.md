# Contributing

Thanks for helping. Keep changes small, generic and easy to review.

## Ground rules
- Generic only: no real app, company, people, ticket keys, paths, devices or secrets. Use `<AI-ROOT>`, `<App-Name>`, `<REPO>`, `<TASK-KEY>`.
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
python3 scripts/update-readme.py --check   # README AUTO sections up to date
rg -n $'\u2014' .      # em-dash check, must be empty
```
If you change an example page or the QA template, re-render its PNG in `docs/images/` (headless Chrome, 2x, under 1 MB).

## Adding a bot
- Add `agents/core/<name>.md` or `agents/optional/<name>.md` with `name`, `description`, `tier: default|strong`, `stage` and `output` frontmatter (no tool-specific fields).
- Run `bash install/gen-adapters.sh` to refresh `.cursor/` and `.claude/` adapters.
- Define input, output (a `contracts/` file) and stage.
- The README Bots table and counts refresh from this frontmatter: run `python3 scripts/update-readme.py` locally, or let the workflow do it.

## Adding a target (AI tool)
1. Check the tool's official docs for its rules file, custom agents, skills, commands and deny-list format, and add the links to the PR.
2. Add emitters to `install/lib.sh` (reuse `emit_agent_tool`, `emit_cmd_*` and the shared `.agents/skills/` where the tool reads them).
3. Add a `<tool>:project` and a `<tool>:*` (global) branch to `install_tool` in `install/install.sh`, and add the name to `ALL_TARGETS`. Pipe every agent through `git_agent` and every rule or command through `git_rules`. Never overwrite a user's own global config file.
4. Test `--dry-run` and real installs into a `mktemp -d` folder with `HOME` pointed at a temp folder, in both `--git=self` and `--git=bots`, and confirm `cursor` / `claude` output is unchanged.
5. Update the Compatibility table in README.md, `install/INSTALL.md` and `install/setup-questions.md`.

## Adding a skill
- Add `skills/<group>/<name>/SKILL.md` with `name`, `description` and a one-line `summary` frontmatter.
- The README Skills table refreshes from `summary`: run `python3 scripts/update-readme.py` locally, or let the workflow do it.
