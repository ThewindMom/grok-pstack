# Keel script paths

After `grok plugin install`, Keel scripts live inside the plugin tree, not in the user's project cwd. `scripts/watch-pr/watch-pr` from the repo root will miss.

## Resolve once per session

Prefer a wrapper from `/setup-keel` when it exists:

```bash
KEEL_SCRIPTS=$(keel-scripts)
```

Otherwise:

```bash
KEEL_SCRIPTS=$(bash "<path-to-this-plugin>/skills/keel/scripts/resolve-scripts.sh")
```

Resolution order inside `resolve-scripts.sh`:

1. Its own directory, when you invoke the file next to the tools
2. `scripts_root` in `.grok/keel.toml` or `~/.grok/keel.toml` (written by `/setup-keel`)
3. `$GROK_PLUGIN_ROOT/skills/keel/scripts`
4. The first `*/skills/keel/scripts` under `~/.grok/plugins`

If that fails, find the loaded `keel` skill's `SKILL.md` and use `../scripts` next to it. Do not guess a path under the user's repo.

`/setup-keel` also writes wrappers under `~/.grok/bin` (`keel-watch-pr`, `keel-orch`, `keel-worktree-audit`, `keel-scripts`). Use those when they exist. Put `~/.grok/bin` on `PATH`.

## Commands

| Tool | Invoke |
|---|---|
| PR watcher | `keel-watch-pr` or `"$KEEL_SCRIPTS/watch-pr/watch-pr"` |
| Orchestrate store | `keel-orch` or `bun "$KEEL_SCRIPTS/orch/orch.ts"` |
| Worktree audit | `keel-worktree-audit` or `"$KEEL_SCRIPTS/worktree-audit.sh"` |

Never `scripts/watch-pr/watch-pr`, `bun scripts/orch/orch.ts`, or `scripts/worktree-audit.sh` from the project cwd unless that cwd is the plugin itself.
