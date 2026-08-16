---
name: setup-keel
description: Configure which Grok models and efforts Keel uses per role. Writes ~/.grok/keel.toml or project .grok/keel.toml. Use for /setup-keel, "configure keel models", or changing Keel's model choices.
---

# Setup Keel

Write a Grok config that overrides Keel's per-role model and effort defaults. Skills read it and fall back to their inline defaults when a key is absent.

Never write `~/.cursor/rules/`. Cursor rules are not loaded as Keel config.

## Where it goes

Ask once, prefer `ask_user_question`:

- **User** (default): `~/.grok/keel.toml` plus `~/.grok/rules/keel.md`
- **Project**: `.grok/keel.toml` plus `.grok/rules/keel.md`

Project wins when both exist. Re-runs overwrite the chosen files so setup stays idempotent.

## Steps

### 1. Detect available models

The only slugs Keel will write are `grok-4.6` and `grok-4.5`. Confirm they resolve on `spawn_subagent` in this session. If a slug is rejected, do not write it.

`inherit-parent` and `auto` are always valid. They mean omit `model` so the child inherits the parent chat model.

### 2. Load current state

If the target `keel.toml` exists, read it. Otherwise start from the defaults in step 5.

### 3. Map and confirm

Show every role with its current model and effort. For panel roles the value is a list. One child runs per entry, so the list length is the panel size.

Keel cannot run four vendors. A panel is four Grok children that differ by model, effort, and persona:

| Slot | Default model | Effort | Persona |
|---|---|---|---|
| A | `grok-4.6` | high | adversarial |
| B | `grok-4.6` | default | quality |
| C | `grok-4.5` | low | mechanical |
| D | `grok-4.6` | high | architecture |

`arena cross-judge pool` is also a list. Arena picks one entry whose effort or persona differs from the parent. There is no other model family to switch to.

`swarm workers` is the default for every swarm worker unless a race names an arm.

Ask whether to accept as-is or change specific roles. Prefer `ask_user_question`.

### 4. Validate

Every real slug must be `grok-4.6` or `grok-4.5`. `inherit-parent` and `auto` always pass. Refuse Claude, GPT, Cursor, and any other slug.

### 5. Write the files

Resolve the installed plugin's scripts directory before writing. This skill lives at `skills/setup-keel/`. The tools live at sibling `skills/keel/scripts/`. Use that absolute path when it contains `worktree-audit.sh`. Otherwise run `skills/keel/scripts/resolve-scripts.sh` from the plugin tree.

Write that path as `scripts_root` at the top of `keel.toml`. Then run `"$scripts_root/install-wrappers.sh"`. It writes `keel-watch-pr`, `keel-orch`, `keel-worktree-audit`, `keel-resolve-scripts`, and `keel-scripts` under `~/.grok/bin`. Tell the user to put `~/.grok/bin` on `PATH` if it is not already.

`keel.toml`:

```toml
# Keel per-role model and effort. Delete a key to fall back to the skill default.
# Models: grok-4.6, grok-4.5, inherit-parent, auto.

# Absolute path to this install's skills/keel/scripts. Playbooks resolve tools through it.
scripts_root = "/absolute/path/to/skills/keel/scripts"

[roles]
"feature, refactoring" = { model = "grok-4.5" }
"bug-fix" = { model = "grok-4.6" }
"perf-issue" = { model = "grok-4.6" }
"hillclimb" = { model = "grok-4.6" }
"judgment and prose" = { model = "grok-4.6", effort = "high" }
"hardest tasks" = { model = "grok-4.6", effort = "high" }
"how explorer" = { model = "grok-4.5" }
"how explainer" = { model = "grok-4.6", effort = "high" }
"why investigators" = { model = "grok-4.5" }
"why synthesizer" = { model = "grok-4.6", effort = "high" }
"reflect tooling" = { model = "grok-4.5" }
"reflect judgment, divergent, synthesizer" = { model = "grok-4.6", effort = "high" }
"swarm workers" = { model = "grok-4.5" }

[[panels.how_critics]]
model = "grok-4.6"
effort = "high"
persona = "adversarial"

[[panels.how_critics]]
model = "grok-4.6"
effort = "default"
persona = "quality"

[[panels.how_critics]]
model = "grok-4.5"
effort = "low"
persona = "mechanical"

[[panels.how_critics]]
model = "grok-4.6"
effort = "high"
persona = "architecture"

[[panels.arena_runners]]
model = "grok-4.6"
effort = "high"
persona = "adversarial"

[[panels.arena_runners]]
model = "grok-4.6"
effort = "default"
persona = "quality"

[[panels.arena_runners]]
model = "grok-4.5"
effort = "low"
persona = "mechanical"

[[panels.arena_runners]]
model = "grok-4.6"
effort = "high"
persona = "architecture"

[[panels.arena_cross_judge]]
model = "grok-4.6"
effort = "high"
persona = "judgment"

[[panels.architect_runners]]
model = "grok-4.6"
effort = "high"
persona = "adversarial"

[[panels.architect_runners]]
model = "grok-4.6"
effort = "default"
persona = "quality"

[[panels.architect_runners]]
model = "grok-4.5"
effort = "low"
persona = "mechanical"

[[panels.architect_runners]]
model = "grok-4.6"
effort = "high"
persona = "architecture"

[[panels.interrogate_reviewers]]
model = "grok-4.6"
effort = "high"
persona = "adversarial"

[[panels.interrogate_reviewers]]
model = "grok-4.6"
effort = "default"
persona = "quality"

[[panels.interrogate_reviewers]]
model = "grok-4.5"
effort = "low"
persona = "mechanical"

[[panels.interrogate_reviewers]]
model = "grok-4.6"
effort = "high"
persona = "architecture"
```

Also write a short always-on rule next to it so new sessions see the mapping.

`~/.grok/rules/keel.md` or `.grok/rules/keel.md`:

```markdown
# Keel models

Read `~/.grok/keel.toml` or `.grok/keel.toml` before any `spawn_subagent` call.
Use only `grok-4.6` and `grok-4.5`. The parent session owns every fan-out.
Children do not spawn. See the keel skill `references/spawn.md`.
Resolve harness tools through `scripts_root` or `~/.grok/bin` (`keel-watch-pr`, `keel-orch`, `keel-worktree-audit`). See the keel skill `references/scripts.md`.
```

### 6. Confirm

Tell the user which files were written, the `scripts_root` value, which wrappers landed in `~/.grok/bin`, and that the mapping applies to new sessions. Re-running this skill updates them.

### 7. Offer a verification skill

If the project has no `verify-*` skill and no existing harness, offer once to run `/create-verification-skill`. On no, move on.
