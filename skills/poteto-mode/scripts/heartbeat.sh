#!/usr/bin/env bash
# Sleep SECONDS (default 1800), then print DONE so a Grok monitor wakes the parent.
# Cursor /loop is not here. Re-arm this after every tick.
set -euo pipefail
sec=${1:-1800}
case "$sec" in
'' | *[!0-9]*)
	echo "usage: pstack-heartbeat [seconds]" >&2
	exit 2
	;;
esac
sleep "$sec"
printf 'DONE\n'
