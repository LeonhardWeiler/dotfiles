---
name: implement-todo
description: Work through the items in AGENT/TODO.md in order and commit after each item. Use this skill when the user wants to implement/work through the TODO list ("work through the todos", "implement the items from todo.md", "implement todo"). Project-independent; paths are relative to the repo root.
user-invocable: true
---

# Work through TODO items & commit them one by one

**Purpose:** Work through the items in `AGENT/TODO.md` in order and implement each
one in code. After **every** item a separate commit follows.

This skill is **project-independent**: it works in any repository that uses an
`AGENT/TODO.md`. All paths are relative to the repo root; run the skill from the
root directory of the respective project.

**Context:** The items in `TODO.md` are often the user's reactions/decisions to
the findings in the health report `AGENT/project-health-report.html` (e.g. "ux-2
fix", "cq-1 fix"). An ID like `UX-2` refers to the finding card of the same name
in the report — read its description + recommendation there when an item refers to
it.

---

## Project setup & verification (if you don't know the codebase yet)

Get a picture of the project first instead of making assumptions:

- Read existing guides like `README.md`, `CLAUDE.md`, `AGENTS.md` or
  `CONTRIBUTING.md` — especially sections on development/tests/build.
- Determine **the project's own verification commands** from the project files
  (e.g. `package.json` scripts, `Makefile`, `justfile`, `Cargo.toml`, `go.mod`,
  `pyproject.toml`, CI config). Use **the package manager/toolchain the project
  intends** — do not guess, derive it from lockfiles/config (e.g. `bun.lock` ->
  Bun, `pnpm-lock.yaml` -> pnpm, `package-lock.json` -> npm).
- Typical verification steps, if present in the project: **formatting/lint**,
  **typecheck**, **tests**, **build**. Run only those relevant to the
  changed side/language each time.
- Note project-specific consistency rules (e.g. mirrored logic that has to be
  kept in sync in several places) — such hints are usually in
  `CLAUDE.md`/`README.md`.

## Before you start

> **Create missing files/folders:** If a file or folder named in this skill does
> not exist yet (e.g. the `AGENT/` folder, `AGENT/TODO.md` or
> `AGENT/project-health-report.html`), **create it** instead of aborting. If
> `AGENT/TODO.md` is new or empty there is nothing to work through — say so
> briefly instead of guessing.

1. Read `AGENT/TODO.md` fully and map to each item what concretely needs doing
   (pull in the matching finding card in the health report if needed).
2. **Create a short plan first** (one commit per item) and state it.
3. **Ask questions** if an item is ambiguous or a real design decision is needed
   — before you start, not midway.

## Per item (in order)

1. **Implement** — make the necessary code changes. Stay within the item's scope;
   do not bundle in unrelated changes.
2. **Verify** — make it green locally before the commit (the project's own
   commands, see above; check only the affected side/language). If a behaviour is
   new/changed, add or update a test if the project has tests.
3. **Commit** — a separate, focused commit with **only** the files of this item
   and a meaningful commit message (a short prefix naming the item, e.g.
   `ux-2 fix: …`). Commit **on the current branch** — do **not** create a new
   branch unasked (unless the user explicitly asks for it).

## Maintain README/docs

If an item changes documented behaviour in the project documentation (`README.md`
etc.: features, security/header details, protocol, deliberate decisions), update
the docs and commit that change **separately afterwards**.

## Maintain CLAUDE.md

Just like the README: if an item changes a function, a behaviour, a command
(build/test/lint), the project structure or a convention documented in
`CLAUDE.md`, **update the `CLAUDE.md` accordingly** and commit that change
**separately afterwards**. If no `CLAUDE.md` exists (yet), do not create one here
— the `create-claude-md` skill is responsible for that.

## Maintain the health report

If an implemented item fixes a finding in `AGENT/project-health-report.html` or
changes its assessment, update the report accordingly: **remove** solved findings
(do not tick them off), keep counters/table of contents consistent. Newly
discovered problems you do not implement may be added as a finding in the report.

## Ground rules

- **One commit per TODO item.** Do not mix items in one commit.
- Do not touch files that do not belong to the current item (in particular do not
  commit other work files in the `AGENT/` folder unasked).
- At the end, report briefly what changed per item and in which commit it landed.
