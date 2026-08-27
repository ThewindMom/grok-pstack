# pstack script paths

After `grok plugin install`, pstack scripts live inside the plugin tree, not in the user's project cwd. `scripts/watch-pr/watch-pr` from the repo root will miss.

## Resolve once per session

Prefer a wrapper from `/setup-pstack` when it exists:

```bash
PSTACK_SCRIPTS=$(pstack-scripts)
```

Otherwise:

```bash
PSTACK_SCRIPTS=$(bash "<path-to-this-plugin>/skills/poteto-mode/scripts/resolve-scripts.sh")
```

Resolution order inside `resolve-scripts.sh`:

1. Its own directory, when you invoke the file next to the tools
2. `scripts_root` in `.grok/pstack.toml` or `~/.grok/pstack.toml` (written by `/setup-pstack`)
3. `$GROK_PLUGIN_ROOT/skills/poteto-mode/scripts`
4. The first `*/skills/poteto-mode/scripts` under `~/.grok/plugins` or `~/.grok/installed-plugins`

If that fails, find the loaded `poteto-mode` skill's `SKILL.md` and use `../scripts` next to it. Do not guess a path under the user's repo.

`/setup-pstack` also writes wrappers under `~/.grok/bin` (`pstack-watch-pr`, `pstack-orch`, `pstack-worktree-audit`, `pstack-scripts`). Use those when they exist. Put `~/.grok/bin` on `PATH`.

## Commands

| Tool | Invoke |
|---|---|
| PR watcher | `pstack-watch-pr` or `"$PSTACK_SCRIPTS/watch-pr/watch-pr"` |
| Orchestrate store | `pstack-orch` or `bun "$PSTACK_SCRIPTS/orch/orch.ts"` |
| Worktree audit | `pstack-worktree-audit` or `"$PSTACK_SCRIPTS/worktree-audit.sh"` |

Never `scripts/watch-pr/watch-pr`, `bun scripts/orch/orch.ts`, or `scripts/worktree-audit.sh` from the project cwd unless that cwd is the plugin itself.
