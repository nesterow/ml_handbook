#!/usr/bin/env bash
# switch-harness.sh — point a given AI coding harness at this repo's AGENTS.md.
#
# Different harnesses look for different instruction filenames:
#   Claude Code  -> CLAUDE.md
#   Cursor       -> AGENTS.md (native, 2026) or legacy .cursorrules
#   Codex/OpenAI -> AGENTS.md (native)
#   Copilot      -> AGENTS.md (native) or legacy .github/copilot-instructions.md
#   Gemini       -> GEMINI.md
#   Windsurf     -> .windsurfrules
#   Aider        -> .aider.conf.yml (read: AGENTS.md)
#
# This script keeps AGENTS.md as the single canonical source and creates a
# symlink (or copy, with --copy) pointing each harness's expected file at it.
# Edit AGENTS.md once; every harness sees the update via the link.
#
# Usage:
#   bash scripts/switch-harness.sh <harness> [--copy] [--list] [--clean]
#
#   <harness>  one of: claude cursor codex copilot gemini windsurf aider all
#   --copy     copy instead of symlink (use on filesystems / CI that dislike symlinks)
#   --list     print the harness→filename table and exit
#   --clean    remove generated harness files (leaves AGENTS.md intact)
#
# Run from the repo root (the directory containing AGENTS.md).
set -euo pipefail

# Resolve repo root = parent of scripts/.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

SOURCE="AGENTS.md"
MODE="link"   # link | copy

# ---------- harness -> target file(s) ----------------------------------------
declare -A TARGETS
TARGETS[claude]="CLAUDE.md"
TARGETS[cursor]=".cursorrules"            # legacy; modern Cursor reads AGENTS.md natively
TARGETS[codex]=""                          # reads AGENTS.md natively — nothing to do
TARGETS[copilot]=".github/copilot-instructions.md"
TARGETS[gemini]="GEMINI.md"
TARGETS[windsurf]=".windsurfrules"
TARGETS[aider]=""                          # handled specially: writes .aider.conf.yml

# ---------- pretty printing ---------------------------------------------------
B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; D=$'\033[2m'; N=$'\033[0m'
say()  { printf '%s\n' "${B}▶ $*${N}"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$N" "$*"; }
note() { printf '  %s·%s  %s\n' "$D" "$N" "$*"; }
warn() { printf '  %s⚠%s  %s\n' "$Y" "$N" "$*"; }
die()  { printf '  %s✗%s %s\n' "$R" "$N" "$*" >&2; exit 1; }

# ---------- helpers -----------------------------------------------------------
make_link() {
    local target="$1"
    local tdir
    tdir="$(dirname "$target")"
    [[ -d "$tdir" ]] || mkdir -p "$tdir"
    [[ -e "$target" || -L "$target" ]] && rm -f "$target"
    if [[ "$MODE" == "copy" ]]; then
        cp "$SOURCE" "$target"
        ok "copied $SOURCE -> $target"
    else
        local relsrc
        relsrc="$(python3 -c "import os.path; print(os.path.relpath('$SOURCE', '$tdir'))")"
        ln -s "$relsrc" "$target"
        ok "linked $target -> $relsrc"
    fi
}

write_aider_conf() {
    if [[ -f .aider.conf.yml ]] && grep -q 'AGENTS.md' .aider.conf.yml; then
        ok ".aider.conf.yml already reads AGENTS.md"
        return
    fi
    printf -- '- read: AGENTS.md\n' >> .aider.conf.yml
    note "added 'read: AGENTS.md' to .aider.conf.yml (aider has no native AGENTS.md)"
}

apply_harness() {
    local h="$1"
    case "$h" in
        claude)    make_link "${TARGETS[claude]}" ;;
        cursor)    make_link "${TARGETS[cursor]}" ;;
        codex)     note "Codex reads AGENTS.md natively — nothing to create" ;;
        copilot)   make_link "${TARGETS[copilot]}" ;;
        gemini)    make_link "${TARGETS[gemini]}" ;;
        windsurf)  make_link "${TARGETS[windsurf]}" ;;
        aider)     write_aider_conf ;;
        *) die "unknown harness '$h' (try --list)" ;;
    esac
}

show_list() {
    cat <<'TBL'
Harness        Native file              Notes
-------------- ------------------------ ----------------------------------------
claude         CLAUDE.md                symlink (or use @AGENTS.md import)
cursor         .cursorrules (legacy)    modern Cursor reads AGENTS.md natively
codex          AGENTS.md                native — nothing to do
copilot        .github/copilot-         modern Copilot agent reads AGENTS.md
               instructions.md
gemini         GEMINI.md
windsurf       .windsurfrules
aider          .aider.conf.yml          adds 'read: AGENTS.md'
TBL
}

clean_generated() {
    say "Removing generated harness files (keeping $SOURCE)"
    for t in CLAUDE.md .cursorrules GEMINI.md .windsurfrules .github/copilot-instructions.md; do
        [[ -e "$t" || -L "$t" ]] && rm -f "$t" && note "removed $t"
    done
    if [[ -f .aider.conf.yml ]] && grep -q 'AGENTS.md' .aider.conf.yml; then
        grep -v 'AGENTS.md' .aider.conf.yml > .aider.conf.yml.tmp && mv .aider.conf.yml.tmp .aider.conf.yml || true
        note "removed AGENTS.md from .aider.conf.yml"
    fi
    ok "clean"
}

# ---------- arg parsing -------------------------------------------------------
[[ $# -eq 0 ]] && { echo "Usage: $0 <harness|all|list|clean> [--copy]" >&2; exit 1; }

case "${1:-}" in
    --list|-l) show_list; exit 0 ;;
    --clean|-c) clean_generated; exit 0 ;;
esac

HARNESS="$1"; shift || true
[[ "${1:-}" == "--copy" ]] && MODE="copy"

[[ -f "$SOURCE" ]] || die "$SOURCE not found — run this from the repo root."

say "Targeting harness: ${B}$HARNESS${N} (mode: $MODE, source: $SOURCE)"
if [[ "$HARNESS" == "all" ]]; then
    for h in claude cursor codex copilot gemini windsurf aider; do apply_harness "$h"; done
else
    apply_harness "$HARNESS"
fi
echo
say "${G}Done.${N} Edit ${B}$SOURCE${N} — every linked harness sees the update."
