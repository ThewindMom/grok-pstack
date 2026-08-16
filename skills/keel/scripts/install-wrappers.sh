#!/usr/bin/env bash
# Write ~/.grok/bin wrappers that point at this plugin's scripts.
# /setup-keel runs this so playbooks can call keel-watch-pr after install.
set -euo pipefail

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ ! -x "$here/worktree-audit.sh" ] || [ ! -e "$here/watch-pr/watch-pr" ]; then
	echo "install-wrappers: $here is not a keel scripts dir" >&2
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

write_wrap keel-watch-pr "$here/watch-pr/watch-pr"
write_wrap keel-worktree-audit "$here/worktree-audit.sh"
write_wrap keel-resolve-scripts "$here/resolve-scripts.sh"

{
	echo '#!/usr/bin/env bash'
	printf 'exec bun %q "$@"\n' "$here/orch/orch.ts"
} > "$bin/keel-orch"
chmod +x "$bin/keel-orch"

write_wrap keel-scripts "$here/resolve-scripts.sh"

printf '%s\n' "$bin"
