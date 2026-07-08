# AGENT_PROMPT.md — instructions for an agent performing a harness switch

> This file is for an AI coding agent that's been asked to "switch the harness" or
> "set up AGENTS.md for &lt;tool&gt;". Hand it this file + the repo path.

## Your task

You are switching the AI-coding-agent instruction file for this repository to match
a target harness. The repo keeps a single canonical **`AGENTS.md`** at its root; the
job is to make the target harness read it under the filename that harness expects.

## Do this

1. **Identify the target harness** from the user's request (claude / cursor / codex /
   copilot / gemini / windsurf / aider / all). If unclear, ask.

2. **Run the provided script** from the repo root — it handles the per-harness
   filename mapping, symlinks (default) or copies (`--copy`), and the Aider special
   case:

   ```bash
   bash scripts/switch-harness.sh <harness>          # symlink (default, recommended)
   bash scripts/switch-harness.sh <harness> --copy    # copy instead (Windows / CI)
   bash scripts/switch-harness.sh all                 # every supported harness
   bash scripts/switch-harness.sh --list              # show the mapping table
   bash scripts/switch-harness.sh --clean             # remove generated files
   ```

   The script resolves the repo root from its own location, so it works regardless of
   cwd. Do not hand-edit the symlinks — let the script create them so the relative
   paths are correct.

3. **Verify** the link/file was created and points at `AGENTS.md`:
   ```bash
   ls -la <target-file>          # should show -> AGENTS.md (or ../AGENTS.md for nested)
   head -1 <target-file>         # should print the AGENTS.md title line
   ```

4. **Report** what you did: which file(s) were created, the mode (symlink/copy), and
   remind the user that **editing `AGENTS.md` updates all linked harnesses
   automatically** (that's the point of the single-source design).

## Why symlinks (default) vs copies

- **Symlink (default):** one source of truth. Edit `AGENTS.md`, every harness sees it.
  Recommended for dev machines on macOS/Linux.
- **Copy (`--copy`):** duplicates the content into each file. Use on Windows, on CI
  runners where symlinks are disabled, or when a harness explicitly warns about
  symlinks. Downside: edits to `AGENTS.md` don't propagate — you must re-run the
  script after edits.

## The harness → filename mapping (authoritative)

These are the filenames each harness natively reads, sourced from the official docs
of each tool (verified July 2026):

| Harness | Reads this file | Native AGENTS.md? |
|---|---|---|
| **Claude Code** | `CLAUDE.md` | no (use this script, or put `@AGENTS.md` inside CLAUDE.md) |
| **Cursor** | `AGENTS.md` (modern) / `.cursorrules` (legacy) | yes (modern); this script makes the legacy file too |
| **Codex / OpenAI** | `AGENTS.md` | yes (nothing to do) |
| **GitHub Copilot agent** | `AGENTS.md` (modern) / `.github/copilot-instructions.md` (legacy) | yes (modern) |
| **Gemini** | `GEMINI.md` | no |
| **Windsurf** | `.windsurfrules` | no |
| **Aider** | none natively; reads `read:` list in `.aider.conf.yml` | no (script adds `read: AGENTS.md`) |

If a harness isn't in this table, **don't guess the filename** — search the web for
that harness's official "instructions file" / "project rules" documentation and
confirm before creating anything.

## Edge cases

- **The harness file already exists (and isn't a symlink to AGENTS.md):** the script
  overwrites it. If the user has hand-customised `CLAUDE.md` etc., warn them first
  and suggest merging their customisations into `AGENTS.md` (the canonical source)
  before running.
- **Claude Code `@import` alternative:** instead of symlinking, you can create a
  one-line `CLAUDE.md` containing just `@AGENTS.md` — Claude expands the import.
  Prefer the symlink (the script does) because it's simpler and works identically.
- **Nested `AGENTS.md`:** some harnesses (Codex, Cursor) walk the directory tree and
  merge nested `AGENTS.md` files with nearest-wins precedence. This repo only needs
  the root file; don't create nested ones unless the user asks.
