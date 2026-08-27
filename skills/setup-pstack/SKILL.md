---
name: setup-pstack
description: Configure which Grok models and efforts pstack uses per role. Writes ~/.grok/pstack.toml or project .grok/pstack.toml. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
---

# Setup pstack

Write a Grok config that overrides pstack's per-role model and effort defaults. Skills read it and fall back to their inline defaults when a key is absent.

Never write `~/.cursor/rules/`. Cursor rules are not loaded as pstack config.

## Where it goes

Ask once, prefer `ask_user_question`:

- **User** (default): `~/.grok/pstack.toml` plus `~/.grok/rules/pstack.md` plus `~/.grok/roles/grok-pstack:*.toml`
- **Project**: `.grok/pstack.toml` plus `.grok/rules/pstack.md` plus `.grok/roles/grok-pstack:*.toml`

Project wins when both exist. Re-runs overwrite the chosen files so setup stays idempotent.

## Steps

### 1. Detect available models

The only slug pstack will write is `grok-4.6`. Confirm it resolves on `spawn_subagent` in this session. If the slug is rejected, do not write it.

`inherit-parent` and `auto` are always valid. They mean omit `model` so the child inherits the parent chat model.

The only efforts pstack will write are `high` and `xhigh`. There is no `grok-4.5` slot, no `low`, no `medium`, no `default`.

### 2. Load current state

If the target `pstack.toml` exists, read it. Otherwise start from the defaults in step 5.

### 3. Map and confirm

Show every role with its current model and effort. For panel roles the value is a list. One child runs per entry, so the list length is the panel size.

pstack cannot run four vendors. A panel is four Grok children that differ by agent type and persona. Every slot is `grok-4.6`. Effort is the type, because `spawn_subagent` has no effort field.

| Slot | Type | Effort | Persona |
|---|---|---|---|
| A | `grok-pstack:pstack-xhigh` | xhigh | adversarial |
| B | `grok-pstack:pstack-high` | high | quality |
| C | `grok-pstack:pstack-high` | high | mechanical |
| D | `grok-pstack:pstack-xhigh` | xhigh | architecture |

Mechanical pstack-style code is `grok-pstack:poteto-agent` (`high`). Judgment pstack-style code is `grok-pstack:poteto-judge` (`xhigh`). Never the built-in `explore` agent. Grok pins it to medium.

`arena cross-judge pool` is also a list. Arena picks one entry whose effort or persona differs from the parent. There is no other model family to switch to.

`swarm workers` is the default for every swarm worker unless a race names an arm.

Ask whether to accept as-is or change specific roles. Prefer `ask_user_question`.

### 4. Validate

Every real slug must be `grok-4.6`. `inherit-parent` and `auto` always pass. Refuse `grok-4.5`, Claude, GPT, Cursor, and any other slug.

Every real effort must be `high` or `xhigh`. Refuse `low`, `medium`, `default`, `max`, `none`, `minimal`.

`spawn_subagent` takes `model`. It does not take `effort`. Pick the agent type from the poteto-mode skill `references/spawn.md`. Write effort into `pstack.toml` so the type mapping stays visible. Write matching Grok roles (`reasoning_effort`) so the type pins effort at spawn, not only in agent YAML. Do not spawn `general-purpose` or `explore` for a pstack role.

### 5. Write the files

Resolve the installed plugin's scripts directory before writing. This skill lives at `skills/setup-pstack/`. The tools live at sibling `skills/poteto-mode/scripts/`. Use that absolute path when it contains `worktree-audit.sh`. Otherwise run `skills/poteto-mode/scripts/resolve-scripts.sh` from the plugin tree.

Write that path as `scripts_root` at the top of `pstack.toml`. Then run `"$scripts_root/install-wrappers.sh"`. It writes `pstack-watch-pr`, `pstack-orch`, `pstack-worktree-audit`, `pstack-heartbeat`, `pstack-check-plan`, `pstack-resolve-scripts`, and `pstack-scripts` under `~/.grok/bin`. Tell the user to put `~/.grok/bin` on `PATH` if it is not already.

This skill lives at `skills/setup-pstack/`. After the wrappers, run `"<this-skill-dir>/install-roles.sh" user` or `project` to match the destination chosen above. It writes `grok-pstack:poteto-agent.toml`, `grok-pstack:poteto-judge.toml`, `grok-pstack:pstack-high.toml`, `grok-pstack:pstack-xhigh.toml`, and `grok-pstack:comment-sicko.toml` into `~/.grok/roles/` or `.grok/roles/`. Each file sets `model = "grok-4.6"` and `reasoning_effort` to `high` or `xhigh`. Grok discovers those filenames as role names, which match the `spawn_subagent` types. Re-runs overwrite them.

`pstack.toml`:

```toml
# pstack per-role model and effort. Delete a key to fall back to the skill default.
# Model: grok-4.6, inherit-parent, auto.
# Effort: high (mechanical), xhigh (judgment). Never grok-4.5.

# Absolute path to this install's skills/poteto-mode/scripts. Playbooks resolve tools through it.
scripts_root = "/absolute/path/to/skills/poteto-mode/scripts"

[roles]
"feature, refactoring" = { model = "grok-4.6", effort = "high" }
"bug-fix" = { model = "grok-4.6", effort = "xhigh" }
"perf-issue" = { model = "grok-4.6", effort = "xhigh" }
"hillclimb" = { model = "grok-4.6", effort = "xhigh" }
"judgment and prose" = { model = "grok-4.6", effort = "xhigh" }
"hardest tasks" = { model = "grok-4.6", effort = "xhigh" }
"how explorer" = { model = "grok-4.6", effort = "high" }
"how explainer" = { model = "grok-4.6", effort = "xhigh" }
"why investigators" = { model = "grok-4.6", effort = "high" }
"why synthesizer" = { model = "grok-4.6", effort = "xhigh" }
"reflect tooling" = { model = "grok-4.6", effort = "high" }
"reflect judgment, divergent, synthesizer" = { model = "grok-4.6", effort = "xhigh" }
"swarm workers" = { model = "grok-4.6", effort = "high" }

[[panels.how_critics]]
model = "grok-4.6"
effort = "xhigh"
persona = "adversarial"

[[panels.how_critics]]
model = "grok-4.6"
effort = "high"
persona = "quality"

[[panels.how_critics]]
model = "grok-4.6"
effort = "high"
persona = "mechanical"

[[panels.how_critics]]
model = "grok-4.6"
effort = "xhigh"
persona = "architecture"

[[panels.arena_runners]]
model = "grok-4.6"
effort = "xhigh"
persona = "adversarial"

[[panels.arena_runners]]
model = "grok-4.6"
effort = "high"
persona = "quality"

[[panels.arena_runners]]
model = "grok-4.6"
effort = "high"
persona = "mechanical"

[[panels.arena_runners]]
model = "grok-4.6"
effort = "xhigh"
persona = "architecture"

[[panels.arena_cross_judge]]
model = "grok-4.6"
effort = "xhigh"
persona = "judgment"

[[panels.architect_runners]]
model = "grok-4.6"
effort = "xhigh"
persona = "adversarial"

[[panels.architect_runners]]
model = "grok-4.6"
effort = "high"
persona = "quality"

[[panels.architect_runners]]
model = "grok-4.6"
effort = "high"
persona = "mechanical"

[[panels.architect_runners]]
model = "grok-4.6"
effort = "xhigh"
persona = "architecture"

[[panels.interrogate_reviewers]]
model = "grok-4.6"
effort = "xhigh"
persona = "adversarial"

[[panels.interrogate_reviewers]]
model = "grok-4.6"
effort = "high"
persona = "quality"

[[panels.interrogate_reviewers]]
model = "grok-4.6"
effort = "high"
persona = "mechanical"

[[panels.interrogate_reviewers]]
model = "grok-4.6"
effort = "xhigh"
persona = "architecture"
```

Also write a short always-on rule next to it so new sessions see the mapping.

`~/.grok/rules/pstack.md` or `.grok/rules/pstack.md`:

```markdown
# pstack models

Read `~/.grok/pstack.toml` or `.grok/pstack.toml` before any `spawn_subagent` call.
Use only `grok-4.6`. Spawn `grok-pstack:poteto-agent` or `grok-pstack:pstack-high` for mechanical work.
Spawn `grok-pstack:poteto-judge` or `grok-pstack:pstack-xhigh` for judgment.
Never `grok-4.5`. Never the built-in `explore` agent. The parent session owns every fan-out.
Grok roles in `~/.grok/roles/grok-pstack:*.toml` pin `reasoning_effort` to match those types.
Children do not spawn. See the poteto-mode skill `references/spawn.md`.
Drive the real surface with the `drive` skill.
Resolve harness tools through `scripts_root` or `~/.grok/bin` (`pstack-watch-pr`, `pstack-orch`, `pstack-worktree-audit`, `pstack-heartbeat`, `pstack-check-plan`). See the poteto-mode skill `references/scripts.md`.
```

### 6. Confirm

Tell the user which files were written, the `scripts_root` value, which wrappers landed in `~/.grok/bin`, which Grok roles landed, and that the mapping applies to new sessions. Re-running this skill updates them.

### 7. Offer a verification skill

If the project has no `verify-*` skill and no existing harness, offer once to run `/create-verification-skill`. On no, move on.
