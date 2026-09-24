# Global rules

## Code

- Aim for the most result with the least code. Prefer deletion over addition.
- Make the smallest change that solves the problem.
- Keep the call hierarchy flat. No wrappers with one caller, no layers for hypothetical needs.
- Put each decision in one place, not repeated across files.
- Write code as Ken Thompson, Rob Pike or djb would: simple, minimal, obvious.
- Fix the root cause. A fault is fixed, not documented in a footnote.
- Delete dead code and unreachable branches. No commented-out code; git log holds history.
- Check library APIs against the installed version, not from memory.
- Do the task directly. Do not leave helper scripts behind unless asked.
- No CI or GitHub Actions unless asked.

## Comments and prose

- No comments by default. A comment only carries what the code cannot, e.g. something that is weirdly done only in this project and would CONFUSE others.
- Never explain why an option was chosen. State the thing and stop.
- Keep docs, READMEs and CLAUDE.md files short.

## Workflow

- Make a plan before larger changes. Ask when something is unclear.
- Commit after each step. Push once when the task is done, not after every commit.
- Provide toolchains and dependencies through a `flake.nix`, not system-wide installs.
- Run the project's checks (typecheck, lint, tests) before every commit that could change their result.
- `AGENT/` holds `TODO.md` and `project-health-report.html`, maintained by the
  skills `implement-todo` and `review-and-update-report`. It is not part of the product.

## Language

- Answer in German. Code, identifiers, commit messages, comments and repo docs in English; use German in docs only where they already are German.
- Write numbers as digits, not words.

## Answers

- Give one recommendation instead of a list of options. Be honest about weak ideas.
- Say what was tested and what was not.

## Git

- Commit subject: lowercase `area: what it does`.
- Use my git config as is (name, email, signing). Never change author or skip signing.
- Rewrite history or force-push only when asked.
- Do not add "Authored by" or "Signed-off-by" lines to commit messages in school projects.

## System

- Arch Linux with KDE, keyboard layout Colemak DH.
- NAS: `root@100.65.0.90` over SSH (OpenMediaVault, Docker).
- Anthropic Pro plan: be economical with tokens, use subagents only when needed.
