---
description: Triage and fix a bug with a proving test
argument-hint: <TASK-KEY or description>
---
Fix this bug: $ARGUMENTS

1. Describe it as Where / Given / When / Then. Find the root cause.
2. Propose the smallest fix; ask before touching shared components.
3. Add a test that fails before and passes after.
4. Run the analyzer gate (fvm if the repo uses it). Stop for my OK. No git.
