### Opening a PR

Invoked at the end of every other playbook.

**Worktree.** Work from a git worktree off main; subagents inherit it. Multiple `spawn_subagent` calls on the same branch each get their own worktree, or `git fetch && git reset --hard origin/<branch>` between them. Dirty branch with unrelated work: patch out, fresh worktree, apply. Snarled worktree: reset from main, redo minimally.

**Commits.** Commit liberally; rebase into small, ordered commits before opening PRs. Each commit is a future PR: landable, ordered to tell the story. Amend when the fix belongs in a just-made commit; new commit when separable.

**PRs.** `/deslop` the diff before commit. A leaf may run `/deslop`; it does not spawn. `/no-comments` the diff before review, in the parent, because it must spawn Comment Sicko. Apply the **unslop** skill to the PR description and commit bodies. Small PRs, 5 narrow over 1 fat; stack follow-ups, branch off main only for genuinely independent work. For stacked PRs, use whatever stacking tool your team uses; the principle is small, ordered slices with the stack visible to reviewers. `gh pr view <number>` before referencing PR status. Rebase on `main` before substantial stack work. No `## Summary` / `## Test plan` boilerplate on small PRs; commit bodies don't restate the subject.

After opening, the parent runs the **Babysit** playbook. Push back when feedback drifts from intent. A leaf that opens a PR returns the URL and head SHA and stops. It does not babysit, does not run `/no-comments`, and does not spawn. `interrogate` and `/no-comments` stay in the parent. Return to the parent.
