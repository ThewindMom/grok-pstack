# pstack

i'm porting [poteto](https://x.com/poteto)'s pstack to Grok Build.

pstack is Lauren Tan's answer to slop. the playbooks and the 21 principles are hers. the harness here is Grok-native: `spawn_subagent`, depth 1, `grok-4.6` / `grok-4.5`. no Cursor `Task`, no cloud agents, no Fable/Sol slugs.

if you want to go fast, go deep first. throughput without quality is not the goal. pstack helps you write less, but higher quality code.

## install

```bash
grok plugin install ThewindMom/grok-pstack --trust
grok plugin enable grok-pstack
```

or from this checkout:

```bash
grok plugin install "$(pwd)" --trust
grok plugin enable grok-pstack
```

then:

```text
/setup-pstack
/poteto-mode
```

`/pstack` is the same command.

## get started

two steps:

1. run `/setup-pstack` and choose which Grok models you want per role.
2. use `/poteto-mode` whenever you're doing anything that requires rigor.

that's it. the other skills are situational; the mode skill uses them for you as needed. out of the box mechanical code goes to `grok-4.5` and judgment goes to `grok-4.6`. `/setup-pstack` changes any of it.

## what `/poteto-mode` does

it reads your request, matches one of twenty-two playbooks, copies those steps into the todo list, and runs the other skills as the steps need them. the first todo is always "read the Principles section."

```text
/poteto-mode this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro
first, then fix and verify.
```

```text
/poteto-mode i'm going to bed. land the stack even if ci flakes. i want everything merged by
morning.
```

it stays on for the conversation until you opt out.

## grok-only facts

**models.** `grok-4.6` (default, judgment) and `grok-4.5` (fast, mechanical). no claude. no gpt. no cursor slugs. multi-model panels in cursor pstack become multi-effort and multi-persona grok children. `/setup-pstack` writes `~/.grok/pstack.toml` or project `.grok/pstack.toml`. it never writes `~/.cursor/rules/`.

**depth is 1.** a grok subagent cannot spawn subagents. cursor pstack playbooks that fanned out from a `poteto-agent` child will silently fail here if you leave them nested. the parent session running `/poteto-mode` owns every `spawn_subagent` call. `grok-pstack:poteto-agent` is a leaf. if a leaf needs more workers, it returns a `FANOUT` block and stops.

**spawn.** use `spawn_subagent`, not cursor `Task`. built-in types are `general-purpose`, `explore`, and `plan`. pstack adds `grok-pstack:poteto-agent` and `grok-pstack:comment-sicko`. grok qualifies plugin agents as `plugin-name:agent-name`.

## playbooks

| playbook | for |
|---|---|
| [investigation](./skills/poteto-mode/playbooks/investigation.md) | a read-only question |
| [bug fix](./skills/poteto-mode/playbooks/bug-fix.md) | reproduce, root-cause, fix with runtime evidence |
| [perf](./skills/poteto-mode/playbooks/perf-issue.md) | measured slowness against a baseline |
| [hillclimb](./skills/poteto-mode/playbooks/hillclimb.md) | sustained improvement of one metric |
| [runtime forensics](./skills/poteto-mode/playbooks/runtime-forensics.md) | live symptom, diagnosis not a fix |
| [trace forensics](./skills/poteto-mode/playbooks/trace-forensics.md) | captured profile, diagnosis not a fix |
| [feature](./skills/poteto-mode/playbooks/feature.md) | new behavior from a named data shape |
| [refactoring](./skills/poteto-mode/playbooks/refactoring.md) | behavior-preserving structure change |
| [prototype](./skills/poteto-mode/playbooks/prototype.md) | throwaway sketch to settle a fork |
| [visual parity](./skills/poteto-mode/playbooks/visual-parity.md) | pixel-exact UI equivalence |
| [authoring a skill](./skills/poteto-mode/playbooks/authoring-a-skill.md) | writing or editing a SKILL.md |
| [eval](./skills/poteto-mode/playbooks/eval.md) | blinded test of a skill or prompt change |
| [babysit](./skills/poteto-mode/playbooks/babysit.md) | drive a PR or stack to merge-ready |
| [shipping](./skills/poteto-mode/playbooks/shipping.md) | independently verify, then land |
| [autonomous run](./skills/poteto-mode/playbooks/autonomous-run.md) | drive a long task to a predicate |
| [orchestrate](./skills/poteto-mode/playbooks/orchestrate.md) | standing project, many stacked PRs |
| [autopilot-full](./skills/poteto-mode/playbooks/autopilot-full.md) | independent PRs to merged |
| [autopilot-stack](./skills/poteto-mode/playbooks/autopilot-stack.md) | linear stack the operator lands |
| [session pickup](./skills/poteto-mode/playbooks/session-pickup.md) | resume in-flight work |
| [pause safely](./skills/poteto-mode/playbooks/pause-safely.md) | suspend so it can be resumed |
| [multi-phase plan](./skills/poteto-mode/playbooks/multi-phase-plan.md) | work that spans phases or stacked PRs |
| [worktree cleanup](./skills/poteto-mode/playbooks/worktree-cleanup.md) | prune merged or abandoned worktrees |

the [guide](./docs/guide/README.md) walks a first real task.

## skills

`/poteto-mode` runs most of these when a step needs them. reach for one directly when you want it.

| skill | when |
|---|---|
| `/poteto-mode` | default entry. `/pstack` is the same |
| `/how` | walkthrough of how a subsystem works |
| `/why` | why it was built this way, from evidence |
| `/recall` | rebuild recent context on a topic |
| `/blast-radius` | what else a small change could break |
| `/architect` | settle types and module shape first |
| `/arena` | N parallel attempts, then graft |
| `/swarm` | N parallel workers, one report |
| `/interrogate` | adversarial review from several grok personas |
| `/automate-me` | draft your own `-mode` skill |
| `/setup-pstack` | pick models and efforts per role |
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

## agents

spawn from the parent with `spawn_subagent`:

- [`grok-pstack:poteto-agent`](./agents/poteto-agent.md). leaf worker. reads poteto-mode including the principles index. cannot spawn.
- [`grok-pstack:comment-sicko`](./agents/comment-sicko.md). comment reviewer. usually through `/no-comments`.

## credit

pstack playbooks and principles are MIT, written by [Lauren Tan](https://x.com/poteto). the Grok harness started as [keel](https://github.com/jexmarc/keel) by Marc. this repo is a fork renamed back to pstack / poteto-mode so it feels like the original on Grok Build.

we did not invent the playbooks or the principles.

## not ported

- **Benny.** Cursor automations for Slack triage. no Grok equivalent. skip.
- **cursor-team-kit** (`control-ui`, `control-cli`). drive the real surface yourself, or generate a project verify skill with `/create-verification-skill`. `/deslop` is reimplemented here.
- **Cursor `/loop`.** use Grok `monitor` and background commands.
- **Cursor cloud `environment` / `cloud_base_branch`.** use `isolation: worktree` or put the ref in the brief.
- **Four-vendor model panels.** replaced by Grok effort and persona slots.

## license

MIT. see [LICENSE](./LICENSE).
