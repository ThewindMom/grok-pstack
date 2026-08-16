# Keel

Rigorous playbook-driven engineering for Grok Build.

Keel is a full port of Lauren Tan's [pstack](https://github.com/cursor/plugins) / poteto-mode. The playbooks and the 21 principles are hers. The harness is ours. We rewrote every Cursor API so this installs as a real Grok plugin.

If you want to go fast, go deep first. Throughput without quality is not the goal. Keel makes Grok run like a small engineering team that deletes more than it adds.

## Install

```bash
grok plugin install jexmarc/keel --trust
```

Then:

```text
/setup-keel
/keel
```

`/keel-mode` is the same command. People who still say poteto-mode get routed here.

## What `/keel` does

It reads your request, matches one of twenty-two playbooks, copies those steps into the todo list, and runs the other skills as the steps need them. The first todo is always "read the Principles section."

```text
/keel this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro
first, then fix and verify.
```

```text
/keel i'm going to bed. land the stack even if ci flakes. i want everything merged by
morning.
```

It stays on for the conversation until you opt out.

## Grok-only facts

**Models.** Keel uses `grok-4.6` (default, judgment) and `grok-4.5` (fast, mechanical). No Claude. No GPT. No Cursor slugs. Multi-model panels in pstack (interrogate, arena, how critics) become multi-effort and multi-persona Grok children. `/setup-keel` writes `~/.grok/keel.toml` or project `.grok/keel.toml`, records `scripts_root`, and installs `~/.grok/bin` wrappers for the plugin scripts. It never writes `~/.cursor/rules/`.

**Depth is 1.** A Grok subagent cannot spawn subagents. pstack playbooks that fanned out from a `poteto-agent` child will silently fail here if you leave them nested. The parent session running `/keel` owns every `spawn_subagent` call. `keel-agent` is a leaf. If a leaf needs more workers, it returns a `FANOUT` block and stops.

**Spawn.** Use `spawn_subagent`, not Cursor `Task`. Built-in types are `general-purpose`, `explore`, and `plan`. Keel adds `keel-agent` and `comment-sicko`.

## Playbooks

| playbook | for |
|---|---|
| [investigation](./skills/keel/playbooks/investigation.md) | a read-only question |
| [bug fix](./skills/keel/playbooks/bug-fix.md) | reproduce, root-cause, fix with runtime evidence |
| [perf](./skills/keel/playbooks/perf-issue.md) | measured slowness against a baseline |
| [hillclimb](./skills/keel/playbooks/hillclimb.md) | sustained improvement of one metric |
| [runtime forensics](./skills/keel/playbooks/runtime-forensics.md) | live symptom, diagnosis not a fix |
| [trace forensics](./skills/keel/playbooks/trace-forensics.md) | captured profile, diagnosis not a fix |
| [feature](./skills/keel/playbooks/feature.md) | new behavior from a named data shape |
| [refactoring](./skills/keel/playbooks/refactoring.md) | behavior-preserving structure change |
| [prototype](./skills/keel/playbooks/prototype.md) | throwaway sketch to settle a fork |
| [visual parity](./skills/keel/playbooks/visual-parity.md) | pixel-exact UI equivalence |
| [authoring a skill](./skills/keel/playbooks/authoring-a-skill.md) | writing or editing a SKILL.md |
| [eval](./skills/keel/playbooks/eval.md) | blinded test of a skill or prompt change |
| [babysit](./skills/keel/playbooks/babysit.md) | drive a PR or stack to merge-ready |
| [shipping](./skills/keel/playbooks/shipping.md) | independently verify, then land |
| [autonomous run](./skills/keel/playbooks/autonomous-run.md) | drive a long task to a predicate |
| [orchestrate](./skills/keel/playbooks/orchestrate.md) | standing project, many stacked PRs |
| [autopilot-full](./skills/keel/playbooks/autopilot-full.md) | independent PRs to merged |
| [autopilot-stack](./skills/keel/playbooks/autopilot-stack.md) | linear stack the operator lands |
| [session pickup](./skills/keel/playbooks/session-pickup.md) | resume in-flight work |
| [pause safely](./skills/keel/playbooks/pause-safely.md) | suspend so it can be resumed |
| [multi-phase plan](./skills/keel/playbooks/multi-phase-plan.md) | work that spans phases or stacked PRs |
| [worktree cleanup](./skills/keel/playbooks/worktree-cleanup.md) | prune merged or abandoned worktrees |

The [guide](./docs/guide/README.md) walks a first real task.

## Skills

`/keel` runs most of these when a step needs them. Reach for one directly when you want it.

| skill | when |
|---|---|
| `/keel` | default entry. `/keel-mode` is the same |
| `/how` | walkthrough of how a subsystem works |
| `/why` | why it was built this way, from evidence |
| `/recall` | rebuild recent context on a topic |
| `/blast-radius` | what else a small change could break |
| `/architect` | settle types and module shape first |
| `/arena` | N parallel attempts, then graft |
| `/swarm` | N parallel workers, one report |
| `/interrogate` | adversarial review from several Grok personas |
| `/automate-me` | draft your own `-mode` skill |
| `/setup-keel` | pick models and efforts per role |
| `/reflect` | capture a session as a skill edit |
| `/teach` | how + why, diagram by diagram |
| `/tdd` | failing test first |
| `/no-comments` | Comment Sicko, then fix accepted flags |
| `/deslop` | strip slop from a code diff |
| `/unslop` | cut AI tells from writing |
| `/typescript-best-practices` | type-system-discipline in TypeScript |
| `/figure-it-out` | no bundled playbook fits |
| `/show-me-your-work` | decision trail |
| `/create-verification-skill` | project-local verify skill |
| `/maintain-verification-skill` | keep the feature map honest |
| `/bro` | restate the last message in plain language |
| `/technical-writing` | docs, RFCs, PR descriptions |

## Agents

Spawn from the parent with `spawn_subagent`:

- [`keel-agent`](./agents/keel-agent.md). Leaf worker. Reads keel including the principles index. Cannot spawn.
- [`comment-sicko`](./agents/comment-sicko.md). Comment reviewer. Usually through `/no-comments`.

## Credit

pstack is MIT, written by [Lauren Tan](https://x.com/poteto). We did not invent the playbooks or the principles. We ported them and rewrote the harness for Grok Build.

## Not ported

- **Benny.** Cursor automations for Slack triage. No Grok equivalent. Skip.
- **cursor-team-kit** (`control-ui`, `control-cli`). Drive the real surface yourself, or generate a project verify skill with `/create-verification-skill`. `/deslop` is reimplemented here.
- **Cursor `/loop`.** Use Grok `monitor` and background commands.
- **Cursor cloud `environment` / `cloud_base_branch`.** Use `isolation: worktree` or put the ref in the brief.
- **Four-vendor model panels.** Replaced by Grok effort and persona slots.

## License

MIT. See [LICENSE](./LICENSE).
