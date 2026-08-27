---
name: drive
description: Drive the real app surface to prove behavior. Use for /drive, live verification lanes, bug repro, visual parity, or any "prove it works" step. Prefer a project verify-* skill. Otherwise Playwright MCP for web, a PTY for CLI/TUI, HTTP for APIs. Never hand the drive to the user.
disable-model-invocation: true
---

# Drive

Prove behavior on the surface a user touches. Tests and "it compiles" are not this skill.

The parent session owns the drive. A leaf that needs a drive returns a `FANOUT` block. See the poteto-mode skill `references/spawn.md`.

## Pick the harness

In order. Stop at the first that can reach the surface.

1. **Project `verify-*` skill.** If `.grok/skills/verify-<app>/` exists, follow it. That is the repo's source of truth.
2. **None exists, and this task will keep proving the same app.** Run `/create-verification-skill` once, then use the skill it wrote.
3. **Web / Electron / browser UI.** Playwright MCP. Call `search_tool` for the schema, then `use_tool`. Do not guess tool names. Screenshot the action and the resulting state.
4. **CLI / TUI.** A PTY or tmux session via `run_terminal_command`. Capture the transcript. Do not simulate the binary with a unit test.
5. **HTTP API.** `curl` against the running server. Capture status, headers, and body.
6. **No way to drive it.** Flag it. Do not ask the user to click through the flow for you.

## Rules

- Exercise the user path, not an internal setter or a test-only endpoint.
- Capture the action and the resulting state, not only the final screen.
- Verify side effects (files, rows, messages) alongside what is visible.
- "Inconclusive" or the wrong surface is a fail.
- Two instances get two ports, data dirs, or profiles. Refusing to double-drive a shared instance beats corrupting the user's session.
- Cleanup kills what this run started. Proof artifacts survive teardown.

## Live lanes (multi-phase plans, swarm verify)

Each lane is one `spawn_subagent`, `subagent_type: grok-pstack:pstack-xhigh`, `capability_mode: all`, `background: true`, its own worktree or `/tmp/drive-<slug>/lane-<n>/`. The brief names the scenario, the screenshot or transcript path, and the pass predicate. Ten lanes means ten children in one parent message.

## Reply

Surface, harness used, what you drove, evidence paths, pass or fail per predicate.
