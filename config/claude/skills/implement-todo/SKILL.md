---
name: implement-todo
description: Work through the items in AGENT/TODO.md in order and commit after each item. Use this skill when the user wants to implement/work through the TODO list ("work through the todos", "implement the items from todo.md", "implement todo"). Project-independent; paths are relative to the repo root.
user-invocable: true
---

# Work through AGENT/TODO.md

Implement the items in `AGENT/TODO.md` in order, one commit per item.

Items are often reactions to findings in `AGENT/project-health-report.html`
(e.g. "ux-2 fix"). An ID like `UX-2` refers to the finding card of that name;
read its description and recommendation there.

## Before you start

- Learn the project from `README.md`, `CLAUDE.md`, `AGENTS.md`,
  `CONTRIBUTING.md`. Derive its format, lint, typecheck, test and build
  commands from the project files (scripts, `Makefile`, `flake.nix`, CI config)
  and use the toolchain the lockfiles point to.
- Create `AGENT/` or `AGENT/TODO.md` if missing. If `TODO.md` is empty, say so
  and stop.
- Read all items, state a short plan (one commit per item), and ask about
  ambiguous items or real design decisions now, not midway.

## Per item, in order

1. Implement it. Stay within the item's scope.
2. Run the project's checks for the affected side. Add or update a test for new
   or changed behaviour if the project has tests.
3. Commit only this item's files on the current branch, in the project's commit
   style (default: `area: what it does`).

If the item changes something documented in `README.md` or `CLAUDE.md`, update
that doc in a separate commit right after. Do not create a missing `CLAUDE.md`;
that is `/init`'s job.

If the item fixes or changes a finding in `AGENT/project-health-report.html`,
remove solved findings (do not tick them off) and keep counters and table of
contents consistent. New problems you do not fix may be added as findings.

## Rules

- One commit per item, no unrelated files, no other `AGENT/` work files.
- No new branch unless asked.
- At the end, list per item what changed and in which commit.
