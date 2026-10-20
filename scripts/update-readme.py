#!/usr/bin/env python3
"""Regenerate the AUTO sections of README.md from agents/, skills/ and CHANGELOG.md.

Usage:
  python3 scripts/update-readme.py          # rewrite README.md if needed
  python3 scripts/update-readme.py --check  # exit 1 if README.md is out of date

Sections are delimited by <!-- AUTO:NAME:START --> ... <!-- AUTO:NAME:END -->.
Stdlib only. No network, no git.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"
CHANGELOG = ROOT / "CHANGELOG.md"

STAGE_ORDER = ["All", "Intake", "Gap", "Plan", "Dev+Tests", "Analyze",
               "Review", "QA", "Report", "Tracker", "Support"]
GROUP_ORDER = ["architecture", "dev", "review", "qa", "team"]
TIERS = [("core", "Required"), ("optional", "Optional")]


def frontmatter(path):
    """Return simple `key: value` pairs from the leading --- block."""
    lines = path.read_text(encoding="utf-8").splitlines()
    data = {}
    if not lines or lines[0].strip() != "---":
        return data
    for line in lines[1:]:
        if line.strip() == "---":
            break
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m:
            data[m.group(1)] = m.group(2).strip()
    return data


def cell(text):
    return text.replace("|", "\\|")


def stage_key(stage):
    return STAGE_ORDER.index(stage) if stage in STAGE_ORDER else len(STAGE_ORDER)


def load_bots():
    bots = {}
    for folder, kind in TIERS:
        items = []
        for f in (ROOT / "agents" / folder).glob("*.md"):
            fm = frontmatter(f)
            name = fm.get("name", f.stem)
            stage = fm.get("stage", "Support")
            role = re.sub(r"\s*\(stage [^)]*\)\.?\s*$", "", fm.get("description", ""))
            items.append((stage_key(stage), name, stage, kind, fm.get("output", ""), role))
        bots[folder] = sorted(items)
    return bots


def bots_table(bots):
    rows = ["| Bot | Stage | Type | Output | Role |", "|---|---|---|---|---|"]
    for folder, _ in TIERS:
        for _, name, stage, kind, output, role in bots[folder]:
            out = f"`{cell(output)}`" if output else ""
            rows.append(f"| {name} | {stage} | {kind} | {out} | {cell(role)} |")
    return "\n".join(rows)


def skills_table():
    rows = ["| Group | Skill | Use |", "|---|---|---|"]
    found = []
    for f in (ROOT / "skills").glob("*/*/SKILL.md"):
        group = f.parent.parent.name
        fm = frontmatter(f)
        gkey = GROUP_ORDER.index(group) if group in GROUP_ORDER else len(GROUP_ORDER)
        found.append((gkey, group, fm.get("name", f.parent.name), fm.get("summary", "")))
    for _, group, name, summary in sorted(found):
        rows.append(f"| {group} | {name} | {cell(summary)} |")
    return "\n".join(rows)


def version_line():
    text = CHANGELOG.read_text(encoding="utf-8")
    m = re.search(r"^##\s+v?(\d+\.\d+\.\d+)\s*\(([^)]+)\)", text, re.M)
    if not m:
        sys.exit("update-readme: no '## x.y.z (date)' heading found in CHANGELOG.md")
    return (f"Latest version: **{m.group(1)}** ({m.group(2)}). "
            f"See [CHANGELOG.md](CHANGELOG.md).")


def replace_section(text, name, content):
    pattern = re.compile(
        r"(<!-- AUTO:%s:START -->)(.*?)(<!-- AUTO:%s:END -->)" % (name, name), re.S)
    m = pattern.search(text)
    if not m:
        sys.exit(f"update-readme: marker AUTO:{name} not found in README.md")
    block = m.group(2).startswith("\n")
    body = f"\n{content}\n" if block else content
    return text[:m.start(2)] + body + text[m.end(2):]


def render(text):
    bots = load_bots()
    core, optional = len(bots["core"]), len(bots["optional"])
    stats = (f"<strong>9 stages &middot; {core} core bots + {optional} optional "
             f"&middot; 1 summary file per stage</strong><br>")
    text = replace_section(text, "VERSION", version_line())
    text = replace_section(text, "STATS", stats)
    text = replace_section(text, "BOTS", bots_table(bots))
    text = replace_section(text, "SKILLS", skills_table())
    text = replace_section(text, "CORE_COUNT", str(core))
    text = replace_section(text, "OPTIONAL_COUNT", str(optional))
    return text


def main():
    check = "--check" in sys.argv[1:]
    old = README.read_text(encoding="utf-8")
    new = render(old)
    if new == old:
        print("README up to date")
        return 0
    if check:
        print("README out of date: run python3 scripts/update-readme.py")
        return 1
    README.write_text(new, encoding="utf-8")
    print("README updated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
