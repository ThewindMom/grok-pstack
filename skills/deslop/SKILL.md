---
name: deslop
description: Strip slop from a code diff before commit. Narrating comments, unsupported guards, dead compatibility paths, unrelated edits. Use for /deslop or before opening a PR.
---

# Deslop

Clean the diff before it is committed. This is the code-side counterpart of `/unslop` (prose) and `/no-comments` (a second pair of eyes on comments).

pstack called this out of `cursor-team-kit`. pstack ships it.

## Scope

The current working tree plus index against the base branch, default `main`, unless the caller named files.

## Strip

1. **Narrating comments.** Phase banners, "add the cards", restated function names. Keep only a non-obvious why the code cannot show.
2. **Unsupported guards.** Nil checks, try/catch, and feature flags that silence a crash instead of fixing the cause. If the root cause is in scope, fix it. If not, leave the crash loud and report it.
3. **Dead compatibility.** Unused adapters, leftover dual-write, "keep this until callers migrate" with no callers.
4. **Unrelated edits.** Formatting sweeps, drive-by renames, files the task did not touch.

## Do not

- Restyle the whole file.
- Invent a helper for a one-off.
- Soften a failing test so the diff looks green.

## Proof

Run the project's typecheck and the tests that cover the touched paths. A deslop that breaks the build is not a cleanup.

## Reply

Files touched, what was deleted, what was left and why.
