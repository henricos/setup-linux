# Context and Guidelines for AI Agents

## Context and references

Before deciding on conventions, flows or rules, check `docs/`. What is documented there is normative: it prevails over assumptions and must be followed. If a decision changes something already documented, update the corresponding document.

For general orientation:

- `README.md` — high-level view for humans; points to `docs/` when something needs detail.
- `docs/` — architectural and technical decisions and cross-cutting procedures of the project.

## Tool-agnostic AI strategy

This project adopts a tool-agnostic strategy to support multiple AIs without duplicating instructions.

**Editable source of truth:**

- `AGENTS.md` — operational rules common to any agent.

Compatibility files such as `CLAUDE.md` are only pointers to this source of truth. Never edit the pointers directly when the intent is to change rules.

## Language

The repository is written entirely in **English**: code, comments, configuration, documentation (`README.md`, `docs/`) and commit messages.

The exception is **operator-facing runtime output**: every message the setup script prints to the person running it (menu labels, prompts, progress, errors, the final summary) is written in **pt-BR** — the script's user interface follows the operator's language.

Chat communication with the operator follows the operator's language (pt-BR).

## Verification

There is no automated test suite. Verification is done by:

- `bash -n` and `shellcheck -x` on every `.sh` file after changes.
- Running the script in a clean container (`ubuntu:24.04` and `debian:12`) to validate menu behavior, generated apt keyrings/sources and idempotent re-runs.
- Items that need systemd, real hardware or WSL (Docker Engine, printer drivers, WSL browser) are validated on a VM or real machine.

## Commits

- Messages always in **English**.
- **Conventional Commits** format: `type: concise subject` (subject up to ~72 characters).
- Valid types: `feat`, `fix`, `docs`, `refactor`, `chore`.
- Subject and body in the imperative mood, describing what the commit does: `add`, `fix`, `update`, `remove`, `refactor`, `document`.
- Body required, with a short paragraph summarizing the goal of the change and a bullet list describing the changes made.
- Before running `git push`, present the proposal and wait for explicit operator approval.
- Use explicit files in `git add`; never broad staging like `git add .`.
- If there are files unrelated to the task outside staging, ask the operator what to do. Never mention pending files in the commit message.
- **NEVER** add AI authorship or attribution trailers (e.g. `Co-Authored-By`, as Claude Code inserts by default), regardless of the tool in use.
- `git push` may be blocked by the tool's sandbox. If that happens, run the push outside the sandbox — do not delegate it to the operator because of a network failure.
