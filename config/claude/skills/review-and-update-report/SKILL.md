---
name: review-and-update-report
description: Full project review (fresh scan) and update of the health report AGENT/project-health-report.html; commits only that report, no code changes. Use this skill when the user wants a project review/health check or wants to update the report ("review the project", "update the report", "health check"). Project-independent; paths are relative to the repo root.
user-invocable: true
---

# Run a project review & update the health report

**Purpose:** Run a full, fresh review of the entire project and bring the health
report `AGENT/project-health-report.html` up to date. **No** code changes are
made - only the report is adjusted and committed.

This skill is **project-independent**: it works in any repository. All paths are
relative to the repo root; run the skill from the root directory of the
respective project.

**Result:** A single commit that changes only
`AGENT/project-health-report.html`.

> **Create missing files/folders:** If a file or folder named in this skill does
> not exist yet (e.g. the `AGENT/` folder or `AGENT/project-health-report.html`
> itself), **create it** instead of aborting. Create the report with the HTML
> base structure described below (title, meta line with date/branch, summary
> counters, table of contents, cards with severity badges, legend) and the three
> sections (Open findings · What is already strong · Deliberately decided).

---

## Step 1 - Analyze the project fully

- Get an overview of the project's structure and purpose first (language,
  framework, entry points, existing docs like `README.md`/`CLAUDE.md`).
- Re-scan the **entire** project (source code + config/CI/docs/tests).
- Assess the **current state of the code**, not earlier report versions. Verify
  every existing finding against the real code before keeping it.
- If the project provides format/lint/test/build commands, check (as far as
  possible without side effects) whether they are green - a broken gate is itself
  a finding. Make **no** code changes to repair them.
- Pay particular attention to:
  - Bugs & correctness
  - Security (auth, input validation, headers, rate limits, leaks)
  - Performance
  - UX & UI/UX consistency
  - Accessibility (a11y)
  - Code quality, maintainability, architecture, technical debt
  - Project structure & cleanliness
  - Missing or fragile tests
  - Documentation gaps
  - Other potential for improvement

While doing so, also check the **`CLAUDE.md`** (if present) against the current
code: are the functions, commands (build/test/lint), project structure and
conventions documented there still correct? An **outdated** `CLAUDE.md` (e.g.
because a function changed) or a **missing** `CLAUDE.md` you record as a
documentation finding (`DOC-*`) with the recommendation to update it or create it
via `create-claude-md`. This skill makes **no** change to the `CLAUDE.md` itself -
it only documents it in the report.

### Actively walk through the central user flows (mandatory)

Do **not** rely on static reading alone - identify the central user/usage flows
of the application (the main entry points and the most important sequences within
them) and walk through them. Look specifically for friction, dead ends, missing
feedback and inconsistencies. Record such insights as `UX-*` findings.

- Determine the relevant flows from the project itself (e.g. screens/pages, CLI
  commands, API endpoints, handlers) - depending on the type of application.
- Walk through **each main flow from start to end**, including branches.
- Consider **edge cases**: error states, interrupted/resumed sequences, missing
  connection/resources, invalid inputs, destructive actions and their
  confirmation, concurrent/nested states.

If possible, **actually start** the application for this and really run the flows
or check them via screenshots (use the project's own start commands); otherwise
walk through them carefully in your head based on the code (entry points, views,
handlers). At every step ask yourself: what does the user want to do here but
cannot? Where do they get stuck? Is feedback or confirmation missing?

## Step 2 - Update `AGENT/project-health-report.html`

Adjust **only** this file. Keep its existing HTML structure and styling (title,
meta line with date/branch, summary counters, table of contents, cards with
severity badges, legend).

Rules for the content:

- The report is a **snapshot** (health check) - it contains **no history**.
- **Delete solved or no-longer-relevant findings entirely.** Do not mark them as
  "Done/Completed", do not archive them - just remove them.
- Add **new insights** from the scan as findings.
- **Update existing findings** if their assessment has changed.
- Every finding has: a short ID, a severity (`critical` -> `high` -> `medium` ->
  `low` -> `info`), the affected file/place, a concise description and a concrete
  recommendation.
- Sort/prioritize clearly from **critical -> optional**.
- Keep the summary counters, the table of contents and the section numbers
  **consistent** with the findings that actually exist.
- Put the current date and the current branch in the meta line.

## Step 3 - No implementations

Make **no** changes outside of `AGENT/project-health-report.html`:

- No fixes, refactorings or new features.
- No formatting or other changes to other files.

## Step 4 - Commit

Create a commit that contains **only** `AGENT/project-health-report.html`, with a
meaningful commit message (e.g. what was added/removed). Commit **on the current
branch** - do **not** create a new branch unasked (unless the user explicitly
asks for it).
