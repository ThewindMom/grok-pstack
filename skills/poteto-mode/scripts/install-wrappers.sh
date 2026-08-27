#!/usr/bin/env bash
# Write ~/.grok/bin wrappers that point at this plugin's scripts.
# /setup-pstack runs this so playbooks can call pstack-watch-pr after install.
set -euo pipefail

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ ! -x "$here/worktree-audit.sh" ] || [ ! -e "$here/watch-pr/watch-pr" ]; then
	echo "install-wrappers: $here is not a pstack scripts dir" >&2
	exit 1
fi

bin="${HOME}/.grok/bin"
mkdir -p "$bin"

write_wrap() {
	local name=$1
	local target=$2
	{
		echo '#!/usr/bin/env bash'
		printf 'exec %q "$@"\n' "$target"
	} > "$bin/$name"
	chmod +x "$bin/$name"
}

write_wrap pstack-watch-pr "$here/watch-pr/watch-pr"
write_wrap pstack-worktree-audit "$here/worktree-audit.sh"
write_wrap pstack-resolve-scripts "$here/resolve-scripts.sh"
write_wrap pstack-heartbeat "$here/heartbeat.sh"
write_wrap pstack-check-plan "$here/check-plan.mjs"

{
	echo '#!/usr/bin/env bash'
	printf 'exec bun %q "$@"\n' "$here/orch/orch.ts"
} > "$bin/pstack-orch"
chmod +x "$bin/pstack-orch"

write_wrap pstack-scripts "$here/resolve-scripts.sh"

printf '%s\n' "$bin"
