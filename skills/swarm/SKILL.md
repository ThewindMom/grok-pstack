---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

Fan out N parallel workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report.

The parent session owns every `spawn_subagent` call. See the poteto-mode skill `references/spawn.md`. Workers are leaves. They do not spawn.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Set N from the user or derive it from the shape. N is total workers.
4. Pick the worker type from `swarm workers` in `~/.grok/pstack.toml` or `.grok/pstack.toml` when present. Otherwise use `grok-pstack:pstack-high`. For a race, name each arm up front (`grok-pstack:pstack-high` vs `grok-pstack:pstack-xhigh`). Never `grok-4.5`. Never the built-in `explore` agent.
5. Give each worker its own writable output when it writes. Use `isolation: worktree`, a branch, or `/tmp/swarm-<slug>/worker-<n>/`.

## Phase B: Fan out

Spawn all N workers in one message with `subagent_type: grok-pstack:pstack-high` (or `grok-pstack:poteto-agent` when the slice is pstack-style implementation, `grok-pstack:pstack-xhigh` for a judgment race arm), `background: true`, and `model: grok-4.6`. Use `isolation: none` when the worker only reads this machine. Use `worktree` when it writes.

There is no Cursor cloud environment and no `cloud_base_branch`. If a worker must start from a non-default pushed branch, put the ref in the brief and have it check that branch out, or set `cwd` to an existing worktree.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

Keep a compact result table, one-line evidenced issues, and explicit gaps or dropouts.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
