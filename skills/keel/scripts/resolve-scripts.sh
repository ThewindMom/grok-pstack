#!/usr/bin/env bash
# Print the absolute path to skills/keel/scripts for an installed Keel plugin.
# Playbooks must call this (or read scripts_root from keel.toml) instead of
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

for f in "${PWD}/.grok/keel.toml" "${HOME}/.grok/keel.toml"; do
	root=$(read_scripts_root "$f" 2>/dev/null) || true
	if [ -n "${root:-}" ] && [ -x "$root/worktree-audit.sh" ]; then
		printf '%s\n' "$root"
		exit 0
	fi
done

if [ -n "${GROK_PLUGIN_ROOT:-}" ] && [ -x "${GROK_PLUGIN_ROOT}/skills/keel/scripts/worktree-audit.sh" ]; then
	printf '%s\n' "${GROK_PLUGIN_ROOT}/skills/keel/scripts"
	exit 0
fi

if [ -d "${HOME}/.grok/plugins" ]; then
	found=$(find "${HOME}/.grok/plugins" -path '*/skills/keel/scripts/worktree-audit.sh' -print -quit 2>/dev/null || true)
	if [ -n "$found" ] && [ -x "$found" ]; then
		printf '%s\n' "$(CDPATH= cd -- "$(dirname -- "$found")" && pwd)"
		exit 0
	fi
fi

echo "keel scripts not found. Run /setup-keel or invoke this file from the plugin tree." >&2
exit 1
