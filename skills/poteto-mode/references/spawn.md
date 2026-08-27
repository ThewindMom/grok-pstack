# Grok spawn contract

pstack runs on Grok Build. Cursor `Task` calls, Cursor model slugs, and nested fan-out from a child will fail here. Use this file.

## Tool

Call `spawn_subagent`. Required: `prompt`, `description`. Optional:

| Field | Values |
|---|---|
| `subagent_type` | `grok-pstack:poteto-agent`, `grok-pstack:poteto-judge`, `grok-pstack:pstack-high`, `grok-pstack:pstack-xhigh`, `grok-pstack:comment-sicko` |
| `background` | `true` for parallel work |
| `capability_mode` | `read-only`, `read-write`, `execute`, `all` |
| `isolation` | `none` (shared tree) or `worktree` |
| `model` | `grok-4.6` only. Omit when the agent frontmatter already pins it. |
| `resume_from` | completed child id, same type |
| `cwd` | working directory. Not with `isolation: worktree` |

`spawn_subagent` has no `effort` field. Effort is the agent type:

| Type | Effort | Use |
|---|---|---|
| `grok-pstack:poteto-agent` | high | pstack-style mechanical code |
| `grok-pstack:poteto-judge` | xhigh | pstack-style judgment code |
| `grok-pstack:pstack-high` | high | explorers, mechanical panel slots, swarm workers |
| `grok-pstack:pstack-xhigh` | xhigh | reviewers, synthesizers, live lanes, judgment panel slots |
| `grok-pstack:comment-sicko` | xhigh | `/no-comments` only |

Do not spawn the built-in `explore` agent. Grok pins it to medium effort. Do not spawn `plan`. Do not spawn `general-purpose` for a pstack role. Those inherit the parent and skip the effort pin.

Put the persona, if any, in the prompt after the brief. The type already sets effort.

Retrieve a background child with `get_command_or_subagent_output`. Kill with `kill_command_or_subagent`.

## Depth is 1

Only the top-level session may spawn. A child that calls `spawn_subagent` gets a depth-limit error.

The parent running `/poteto-mode` (or the main session that invoked a workflow skill) owns every fan-out. Every plugin agent above is a leaf. If a leaf needs more workers, it returns a `FANOUT` block and stops.

Do not write playbooks that assume a child will spawn its own children. That is the Cursor pstack shape. It is wrong here.

Grok registers this plugin's agents as `grok-pstack:<name>`. Spawn those ids, not the bare filenames.

`/no-comments` must spawn Comment Sicko. The babysit loop stays in the parent. A leaf that opens a PR returns the URL and head SHA and stops. See `playbooks/opening-a-pr.md`.

Harness tools (`watch-pr`, `orch`, `worktree-audit`, `heartbeat`, `check-plan`) live in the plugin tree. Resolve them per `scripts.md`. Never run `scripts/...` from the user's project cwd.

## Who to spawn

| Work | Type | Notes |
|---|---|---|
| Mechanical pstack-style code | `grok-pstack:poteto-agent` | Feature, refactoring, most writers. |
| Judgment pstack-style code | `grok-pstack:poteto-judge` | Bug-fix, perf, hillclimb. |
| Comment review | `grok-pstack:comment-sicko` | Leaf. Report only. |
| How explorers, swarm workers, panel B/C | `grok-pstack:pstack-high` | Read-only when the slice only reads. |
| How explainer, why synthesizer, panel A/D, live lanes | `grok-pstack:pstack-xhigh` | Persona in the prompt for panel slots. |

Routed workflow skills set their own type from this table. Do not override those to `poteto-agent`.

## Models and panels

pstack's only slug is `grok-4.6`. Mechanical work is the `*-high` agents. Judgment is the `*-xhigh` / `poteto-judge` agents. No `grok-4.5`. No Claude. No GPT. No Cursor slugs.

A four-vendor panel becomes four Grok children that differ by agent type and persona:

1. `grok-pstack:pstack-xhigh`, adversarial
2. `grok-pstack:pstack-high`, quality / instruction-following
3. `grok-pstack:pstack-high`, mechanical
4. `grok-pstack:pstack-xhigh`, architecture

`/setup-pstack` writes `~/.grok/pstack.toml` (or project `.grok/pstack.toml`). Skills read that file. A missing key keeps the skill default. `inherit-parent` or `auto` means omit `model` still, but still pick the high or xhigh *type*.

There is no separate model family to pick a cross-judge from. Pick the unused type (`pstack-high` vs `pstack-xhigh`) or the unused persona instead.

## Capability

`read-only` still sees connected MCP tools on Grok. Use it for reviewers and explorers. Use `all` when the child must run shell or write files. Investigators that query MCP and also run `gh` need `all` or `execute`. Live lanes that drive a UI need `all`.

## Isolation

Writers that would collide get `isolation: worktree` or their own `/tmp/<skill>-<slug>/worker-<n>/`. Readers stay on `none`.

Grok has no Cursor cloud `environment` and no `cloud_base_branch`. Start a child from a pushed branch by putting the ref in the prompt and having it check that branch out, or by setting `cwd` to an existing worktree.

## Parallel

One parent message, many `spawn_subagent` calls. That is the fan-out.

## Resume

`resume_from` continues a finished child of the same type. Directives decay across resumes. Prefer a fresh spawn with a consolidated brief.
