#!/usr/bin/env bash
# Print the absolute path to skills/poteto-mode/scripts for an installed pstack plugin.
# Playbooks must call this (or read scripts_root from pstack.toml) instead of
# running scripts/watch-pr/watch-pr from the user's project cwd.
set -u

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ -x "$here/worktree-audit.sh" ] && [ -x "$here/watch-pr/watch-pr" ]; then
	printf '%s\n' "$here"
	exit 0
fi

read_scripts_root() {
	local f=$1
	[ -f "$f" ] || return 1
	# toml: scripts_root = "/abs/path"
	awk -F= '/^[[:space:]]*scripts_root[[:space:]]*=/ {
		gsub(/^[ \t"]+|[ \t"]+$/, "", $2)
		if ($2 != "") { print $2; exit }
	}' "$f"
}

for f in "${PWD}/.grok/pstack.toml" "${HOME}/.grok/pstack.toml"; do
	root=$(read_scripts_root "$f" 2>/dev/null) || true
	if [ -n "${root:-}" ] && [ -x "$root/worktree-audit.sh" ]; then
		printf '%s\n' "$root"
		exit 0
	fi
done

if [ -n "${GROK_PLUGIN_ROOT:-}" ] && [ -x "${GROK_PLUGIN_ROOT}/skills/poteto-mode/scripts/worktree-audit.sh" ]; then
	printf '%s\n' "${GROK_PLUGIN_ROOT}/skills/poteto-mode/scripts"
	exit 0
fi

for root in "${HOME}/.grok/plugins" "${HOME}/.grok/installed-plugins"; do
	if [ -d "$root" ]; then
		found=$(find "$root" -path '*/skills/poteto-mode/scripts/worktree-audit.sh' -print -quit 2>/dev/null || true)
		if [ -n "$found" ] && [ -x "$found" ]; then
			printf '%s\n' "$(CDPATH= cd -- "$(dirname -- "$found")" && pwd)"
			exit 0
		fi
	fi
done

echo "pstack scripts not found. Run /setup-pstack or invoke this file from the plugin tree." >&2
exit 1
