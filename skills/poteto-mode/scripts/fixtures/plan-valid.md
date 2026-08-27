# Export retry plan

Stop duplicate rows on retry. The operator merges pr-1 then pr-2.

## How to read this

One box is one unit of work. Every box names the evidence that checks it. A nested box is a sub-step of the box above it. Check a box only when its evidence exists, a file, a log line, a screenshot, a test run, or a SHA. The body is a how-to. The appendices explain and record.

The program runs `playbooks/autopilot-stack.md`. The operator lands both PRs.

Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

### Arm the program

- [ ] State the protocol and this plan to the operator, then stop.
- [ ] On her go, arm a Grok monitor on `pstack-heartbeat 1800` (30-minute tick).
- [ ] Read the drive skill from the installed plugin.
- [ ] Then send the operator a status message.

### Spawn owners

- [ ] Spawn one owner per PR.

### PR mechanics, for every PR

- [ ] Open the PR ready.

### Verdict and merge, for every PR

- [ ] Swarm the ten live lanes.

### Boot recipe, for every live lane

- [ ] Drive through the drive skill.

## Deduplicate export rows (pr-1)

**Depends on.** None.

**Files.**

- [ ] Edit `export.ts`.

**Build.**

- [ ] Make `exportRows` skip a retry with the same idempotency key.

**You see.**

- [ ] Log line `skip retry key=`.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] `export.test.ts` covers a mid-run retry. Run `bun test`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.6` xhigh at the PR head, per the boot recipe.

- [ ] Lane 1. First export. Save `l1.png`. Pass when one row exists.
- [ ] Lane 2. Retry mid-run. Save `l2.png`. Pass when still one row.
- [ ] Lane 3. Two keys. Save `l3.png`. Pass when two rows exist.
- [ ] Lane 4. Empty input. Save `l4.png`. Pass when zero rows.
- [ ] Lane 5. Cancel then retry. Save `l5.png`. Pass when one row exists.
- [ ] Lane 6. Parallel retries. Save `l6.png`. Pass when one row exists.
- [ ] Lane 7. Crash after write. Save `l7.png`. Pass when one row exists.
- [ ] Lane 8. Crash before write. Save `l8.png`. Pass when the retry writes one row.
- [ ] Lane 9. Large batch. Save `l9.png`. Pass when count matches input.
- [ ] Lane 10. Auth failure. Save `l10.png`. Pass when no row is written.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Export wall time for 10k rows.
- [ ] Probe. `scripts/bench-export.sh` at trunk and at the head.
- [ ] Baseline. Record the trunk value first.
- [ ] Rule. Head must not exceed trunk plus 10 percent.

**Review gate.** None. pr-1 is not review-gated.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.

## Close the program

- [ ] Every box above is checked with its evidence.

## Appendix A. Prototype evidence

Retry sketch on branch `proto/export` at SHA `deadbeef`.
