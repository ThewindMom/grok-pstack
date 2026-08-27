# Set up pstack

In this page you install the plugin, pick which models pstack uses, and run your first task. Setup is one command plus a short conversation.

## Install the plugin

```bash
grok plugin install ThewindMom/grok-pstack --trust
```

Grok loads the skills, commands, and agents. `--trust` is required so hooks and skills actually activate.

## Pick your models

Run:

```text
/setup-pstack
```

[`/setup-pstack`](../../skills/setup-pstack/SKILL.md) confirms `grok-4.6`, shows you each role (code delegates, judgment, the review panels), and asks what you want. Mechanical work is `high`. Judgment is `xhigh`. It never writes `grok-4.5`. Answer the questions. It writes `~/.grok/pstack.toml` or project `.grok/pstack.toml`, plus a short rule next to it. It also writes `scripts_root` and installs `~/.grok/bin` wrappers (`pstack-watch-pr`, `pstack-orch`, `pstack-worktree-audit`) so playbooks can find the plugin scripts after install. It never writes Cursor rules.

You only override what you care about. A role with no key keeps the skill's default. To restore a default later, delete that key, or just run `/setup-pstack` again.

pstack cannot run four vendors. A panel is four `grok-4.6` children that differ by effort (`high` or `xhigh`) and persona. Set a role to `inherit-parent` or `auto` and pstack omits `model`, so the child inherits your parent chat model. For a panel role the value is a list, and one child runs per entry, so the list length sets the panel size. Setup also configures `swarm workers`, the default model for every `/swarm` worker unless a race names an arm.

## Accept the verification offer, or don't

At the end of setup, `/setup-pstack` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.grok/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `/create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers when it earns its place.

After setup, start a new session. The mapping applies to new sessions.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/poteto-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. The first item is always "read the Principles section". The rest are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/poteto-mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. `/poteto-mode` is sticky. It stays on for the conversation until you opt out by saying so. `/poteto-mode` is the same command.

Next: [Route work through `/poteto-mode`](./02-pstack.md).
