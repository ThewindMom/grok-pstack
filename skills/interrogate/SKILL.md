---
name: interrogate
description: "Use for \"interrogate\", \"adversarial review\", \"multi-persona review\", \"challenge this\", \"stress test this code\", \"find blind spots\", or \"tear this apart\". Multiple Grok reviewers challenge changes from independent angles."
disable-model-invocation: true
---

# Interrogate

Spawn one reviewer per configured panel slot to adversarially review code changes. Each reviewer gets the same prompt and rubric. The adversarial signal comes from effort and persona diversity, not four vendors. Agreement across slots is high-confidence signal; lone-slot findings are worth reading but lower confidence.

The parent session owns every `spawn_subagent` call. See the poteto-mode skill `references/spawn.md`. Reviewers are leaves.

The deliverable is a synthesized verdict. Do NOT auto-apply changes.

## Step 1, Determine Scope

Identify what to review from context:

- If the user points at specific files or a diff, use that
- If on a feature branch, run `git diff main...HEAD` (or the appropriate base branch) for the full changeset
- If the user's message references recent work, gather the relevant files

Package the diff (or file contents) plus any surrounding context files the reviewers need to understand the code.

## Step 2, State the Intent

Before spawning reviewers, state the intent explicitly. What is this code trying to accomplish? Derive this from:

- The user's message
- Commit messages
- PR description if one exists
- The code itself

Write one clear paragraph. Reviewers challenge whether the work achieves the intent well, not whether the intent itself is correct. If you're unsure about the intent, ask the user before proceeding.

## Step 3, Spawn Reviewers

Launch all reviewers in a single message using `spawn_subagent`. Use `panels.interrogate_reviewers` from `~/.grok/pstack.toml` or `.grok/pstack.toml` when present, one reviewer per entry; otherwise use the table defaults.

| Slot | Type | Effort | Persona |
|---|---|---|---|
| A | `grok-pstack:pstack-xhigh` | xhigh | adversarial |
| B | `grok-pstack:pstack-high` | high | quality |
| C | `grok-pstack:pstack-high` | high | mechanical |
| D | `grok-pstack:pstack-xhigh` | xhigh | architecture |

For each reviewer:
- `subagent_type` from the panel
- `model`: `grok-4.6`
- `capability_mode`: `read-only`
- `background`: `true`

Put the persona in the prompt. If a model slug is rejected, keep the type and keep going. Never `grok-4.5`. If the configured value is `inherit-parent` or `auto`, omit `model` and still spawn the high or xhigh type.

Read `references/reviewer-prompt.md` and fill in the template with:
1. The stated intent
2. The diff or file contents
3. The review rubric from `references/rubric.md`
4. The code-quality lens from `references/code-quality-review.md`

The same filled template goes to all reviewers, so every slot applies the code-quality lens.

Each reviewer produces structured findings as described in the prompt template.

## Step 4, Synthesize

As results come back, build a unified picture:

1. **Parse all findings** from the reviewers
2. **Identify consensus**. Findings raised by 2+ slots independently are highest signal.
3. **Identify lone-slot findings**. Still worth reading, but weight accordingly.
4. **Deduplicate**. Different personas may describe the same issue differently. Merge these and note which slots raised it.
5. **Note disagreements**. If one slot flags something and another explicitly says the opposite, that's useful context for the verdict.

## Step 5, Lead Judgment

You are the lead reviewer, a pragmatic senior engineer, not a neutral aggregator.

Read `references/lead-judgment.md` for the full framework. Reviewers only see a slice of the codebase. You have the full context (the goal, the constraints, the timeline, which tradeoffs were already considered). Use that context aggressively.

Categorize every finding using these buckets:

- **Act on**. Real issues affecting correctness, security, or maintainability given the actual goals. These would block a real PR.
- **Consider**. Legitimate points, but you're not sure they outweigh the cost of addressing them right now. Worth the user's attention.
- **Noted**. Technically valid but not actionable. Context-dependent, premature optimization, or low-impact given the current stage.
- **Dismissed**. Wrong, nitpicky, or missing context. Brief explanation why.

For each finding, include:
- Which slot(s) raised it
- The category (act on / consider / noted / dismissed)
- A one-line rationale for the categorization

## Output Format

Present the verdict in this structure:

### Intent
> [The stated intent paragraph from Step 2]

### Reviewers
- Reviewer [label]: [model / persona], [N findings] (one bullet per reviewer)

### Act On
[Findings that should be addressed. For each: description, which slots raised it, why it matters.]

### Consider
[Findings worth thinking about. For each: description, which slots raised it, tradeoff involved.]

### Noted
[Valid but low-priority. Brief list.]

### Dismissed
[Rejected findings with brief rationale. This shows the user what was filtered out and why, so they can override your judgment if they disagree.]

### Agreement Map
[Where did slots agree, where did they diverge, and what does the pattern of agreement/disagreement tell us?]
