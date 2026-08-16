# Grok spawn contract

Keel runs on Grok Build. Cursor `Task` calls, Cursor model slugs, and nested fan-out from a child will fail here. Use this file.

## Tool

Call `spawn_subagent`. Required: `prompt`, `description`. Optional:

| Field | Values |
|---|---|
| `subagent_type` | `keel-agent`, `comment-sicko`, `general-purpose`, `explore`, `plan` |
| `background` | `true` for parallel work |
| `capability_mode` | `read-only`, `read-write`, `execute`, `all` |
| `isolation` | `none` (shared tree) or `worktree` |
| `model` | `grok-4.6` or `grok-4.5` only |
| `resume_from` | completed child id, same type |
| `cwd` | working directory. Not with `isolation: worktree` |

Retrieve a background child with `get_command_or_subagent_output`. Kill with `kill_command_or_subagent`.

## Depth is 1

Only the top-level session may spawn. A child that calls `spawn_subagent` gets a depth-limit error.

The parent running `/keel` (or the main session that invoked a workflow skill) owns every fan-out. `keel-agent` is a leaf. If a leaf needs more workers, it returns a `FANOUT` block and stops.

Do not write playbooks that assume a child will spawn its own children. That is the pstack Cursor shape. It is wrong here.

`/no-comments` must spawn Comment Sicko. The babysit loop stays in the parent. A leaf that opens a PR returns the URL and head SHA and stops. See `playbooks/opening-a-pr.md`.

Harness tools (`watch-pr`, `orch`, `worktree-audit`) live in the plugin tree. Resolve them per `scripts.md`. Never run `scripts/...` from the user's project cwd.

## Who to spawn

| Work | Type | Notes |
|---|---|---|
| Code, playbook slice, keel style | `keel-agent` | Leaf. Reads keel + principles. |
| Comment review | `comment-sicko` | Leaf. Report only. |
| How / why / arena / swarm / interrogate / reflect workers | `general-purpose` or `explore` | Parent sets the persona in the prompt. |
| Read-only codebase hunt | `explore` | No file edits. |

Routed workflow skills set their own type. Do not override those to `keel-agent`.

## Models and panels

Marc's models are `grok-4.6` (default, judgment) and `grok-4.5` (fast, mechanical). No Claude. No GPT. No Cursor slugs.

A four-vendor panel becomes four Grok children that differ by model, effort, and persona in the prompt:

1. `grok-4.6` high effort, adversarial
2. `grok-4.6` default effort, quality / instruction-following
3. `grok-4.5` low effort, mechanical
4. `grok-4.6` high effort, architecture

`/setup-keel` writes `~/.grok/keel.toml` (or project `.grok/keel.toml`). Skills read that file. A missing key keeps the skill default. `inherit-parent` or `auto` means omit `model`.

There is no separate model family to pick a cross-judge from. Pick the unused effort or the unused persona instead.

## Capability

`read-only` still sees connected MCP tools on Grok. Use it for reviewers and explorers. Use `all` when the child must run shell or write files. Investigators that query MCP and also run `gh` need `all` or `execute`.

## Isolation

Writers that would collide get `isolation: worktree` or their own `/tmp/<skill>-<slug>/worker-<n>/`. Readers stay on `none`.

Grok has no Cursor cloud `environment` and no `cloud_base_branch`. Start a child from a pushed branch by putting the ref in the prompt and having it check that branch out, or by setting `cwd` to an existing worktree.

## Parallel

One parent message, many `spawn_subagent` calls. That is the fan-out.

## Resume

`resume_from` continues a finished child of the same type. Directives decay across resumes. Prefer a fresh spawn with a consolidated brief.
