#!/usr/bin/env bash
# Write Grok subagent roles so plugin agent types pin reasoning_effort.
# spawn_subagent has no effort field. Grok roles do.
# Usage: install-roles.sh [user|project]
# user (default): ~/.grok/roles/grok-pstack:<name>.toml
# project: .grok/roles/grok-pstack:<name>.toml from cwd
set -euo pipefail

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
src="$here/roles"
if [ ! -f "$src/poteto-agent.toml" ]; then
	echo "install-roles: $src has no poteto-agent.toml" >&2
	exit 1
fi

scope=${1:-user}
case "$scope" in
user)
	dest="${HOME}/.grok/roles"
	;;
project)
	dest="$(pwd)/.grok/roles"
	;;
*)
	echo "usage: install-roles.sh [user|project]" >&2
	exit 2
	;;
esac

mkdir -p "$dest"

for name in poteto-agent poteto-judge pstack-high pstack-xhigh comment-sicko; do
	cp "$src/$name.toml" "$dest/grok-pstack:${name}.toml"
done

printf '%s\n' "$dest"
