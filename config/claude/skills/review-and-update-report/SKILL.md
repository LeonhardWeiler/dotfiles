---
name: review-and-update-report
description: Full project review (fresh scan) and update of the health report AGENT/project-health-report.html; commits only that report, no code changes. Use this skill when the user wants a project review/health check or wants to update the report ("review the project", "update the report", "health check"). Project-independent; paths are relative to the repo root.
user-invocable: true
---

# Review the project and update the health report

Run a fresh review of the whole project and bring
`AGENT/project-health-report.html` up to date. The result is one commit that
changes only that file.

If `AGENT/` or the report is missing, create it: self-contained HTML with title,
meta line (date, branch), summary counters, table of contents, finding cards with
severity badges, a legend, and 3 sections: Open findings · What is already
strong · Deliberately decided.

## 1. Analyze

- Learn the project's purpose, stack and entry points from its files and docs.
- Scan everything: source, config, CI, docs, tests. Judge the current code, not
  earlier report versions; verify every existing finding before keeping it.
- Run the project's format, lint, test and build commands where that has no side
  effects. A broken gate is a finding; do not repair it.
- Look at: bugs, security (auth, input validation, headers, rate limits, leaks),
  performance, UX and UI consistency, accessibility, code quality and
  architecture, project structure, missing or fragile tests, documentation.
- Check `CLAUDE.md` against the code. An outdated or missing one is a `DOC-*`
  finding (recommend updating it, or `/init`). Do not edit it.

### Walk the main user flows

Identify the central flows (screens, CLI commands, endpoints, handlers) and walk
each from start to end, including branches and edge cases: errors, interrupted
sequences, missing resources, invalid input, destructive actions, nested state.
Run the app with the project's own start command if possible, otherwise trace
the code. Record friction, dead ends and missing feedback as `UX-*` findings.

## 2. Update the report

Keep its HTML structure and styling.

- It is a snapshot without history: delete solved or irrelevant findings, do not
  mark them done.
- Add new findings, update changed ones.
- Each finding has an ID, a severity (`critical`, `high`, `medium`, `low`,
  `info`), the affected file, a short description and a concrete recommendation.
- Sort from critical to info. Keep counters, table of contents and section
  numbers consistent.
- Put today's date and the current branch in the meta line.

## 3. Commit

Change nothing outside the report. Commit only the report on the current branch,
no new branch unless asked.
