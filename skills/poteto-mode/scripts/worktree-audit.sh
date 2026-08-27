#!/usr/bin/env bash
# Read-only worktree prune audit. Classifies every git worktree by size, merge
# state, uncommitted work, remote/PR state, and the most recent Grok chat that
# operated in it. Emits a table sorted by size with a suggested bucket. Never
# deletes anything; deletion stays a human-gated step in the playbook.
#
# Usage: worktree-audit.sh [repo-path]   (defaults to the current repo)
#
# Transcripts: Grok session dirs only. Never ~/.cursor/projects/.
# If no transcript corpus is found, LAST_CHAT is "unscanned" and BUCKET is
# never "safe". An empty scan must not authorize deletion.
set -u

file_mtime() {
	local p=$1
	if stat -c '%Y' "$p" >/dev/null 2>&1; then
		stat -c '%Y' "$p"
	elif stat -f '%m' "$p" >/dev/null 2>&1; then
		stat -f '%m' "$p"
	else
		echo 0
	fi
}

fmt_day() {
	local ts=$1
	date -d "@$ts" '+%Y-%m-%d' 2>/dev/null || date -r "$ts" '+%Y-%m-%d' 2>/dev/null || echo "?"
}

collect_transcript_roots() {
	local repo=$1
	[ -n "${GROK_SESSION_DIR:-}" ] && [ -d "$GROK_SESSION_DIR" ] && printf '%s\n' "$GROK_SESSION_DIR"
	[ -d "$HOME/.grok/sessions" ] && printf '%s\n' "$HOME/.grok/sessions"
	[ -d "$HOME/.grok/transcripts" ] && printf '%s\n' "$HOME/.grok/transcripts"
	[ -d "$repo/.grok/transcripts" ] && printf '%s\n' "$repo/.grok/transcripts"
	[ -d "$repo/.grok/sessions" ] && printf '%s\n' "$repo/.grok/sessions"
	[ -n "${GROK_PLUGIN_DATA:-}" ] && [ -d "$GROK_PLUGIN_DATA/transcripts" ] && printf '%s\n' "$GROK_PLUGIN_DATA/transcripts"
}

repo="${1:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -z "$repo" ] && { echo "not in a git repo; pass a repo path" >&2; exit 1; }
cd "$repo" || exit 1

main_wt=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')

git fetch origin main --quiet 2>/dev/null || echo "warn: could not fetch origin/main; merged column may be stale" >&2

prs=$(mktemp)
gh pr list --author "@me" --state all --limit 1000 \
	--json number,state,headRefName 2>/dev/null > "$prs" || echo "[]" > "$prs"

roots=$(mktemp)
collect_transcript_roots "$repo" | awk 'NF && !seen[$0]++' > "$roots"
scan_ok=no
if [ -s "$roots" ]; then
	while IFS= read -r root; do
		if find "$root" -type f \( -name '*.jsonl' -o -name '*.json' -o -name '*.md' \) -print -quit 2>/dev/null | grep -q .; then
			scan_ok=yes
			break
		fi
	done < "$roots"
fi
if [ "$scan_ok" != yes ]; then
	echo "warn: no Grok transcript corpus found; LAST_CHAT=unscanned and no row will be bucketed safe" >&2
fi

now=$(date +%s)

printf "SIZE\tAGE\tMERGED\tDIRTY\tREMOTE\tPR\tLAST_CHAT\tBUCKET\tWORKTREE\n"

git worktree list --porcelain | awk '/^worktree /{print $2}' | while read -r wt; do
	[ "$wt" = "$main_wt" ] && continue

	size=$(du -sh "$wt" 2>/dev/null | awk '{print $1}')
	head=$(git -C "$wt" rev-parse HEAD 2>/dev/null)
	head_ts=$(git -C "$wt" log -1 --format='%ct' HEAD 2>/dev/null || echo 0)
	age=$([ "$head_ts" -gt 0 ] 2>/dev/null && echo "$(( (now - head_ts) / 86400 ))d" || echo "?")

	git merge-base --is-ancestor "$head" origin/main 2>/dev/null && merged=YES || merged=no

	porcelain=$(git -C "$wt" status --porcelain 2>/dev/null)
	if [ -z "$porcelain" ]; then dirty=clean
	elif printf '%s\n' "$porcelain" | grep -qv '^??'; then
		dirty="wip:$(printf '%s\n' "$porcelain" | grep -cv '^??')"
	else dirty="scratch:$(printf '%s\n' "$porcelain" | grep -c '^??')"; fi

	branch=$(git -C "$wt" symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")
	if [ -z "$branch" ]; then remote=detached
	elif git -C "$wt" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
		[ "$(git -C "$wt" rev-parse "origin/$branch" 2>/dev/null)" = "$head" ] \
			&& remote=pushed \
			|| remote="ahead$(git -C "$wt" rev-list --count "origin/$branch..HEAD" 2>/dev/null)"
	else remote=no-remote; fi

	pr=$([ -n "$branch" ] && jq -r --arg b "$branch" \
		'.[] | select(.headRefName==$b) | "#\(.number)/\(.state)"' "$prs" 2>/dev/null | head -1)
	[ -z "$pr" ] && pr="-"

	last="-"; last_ts=0
	if [ "$scan_ok" = yes ]; then
		while IFS= read -r root; do
			[ -d "$root" ] || continue
			while IFS= read -r f; do
				[ -n "$f" ] || continue
				if grep -q -F -e "${wt}/" -e "${wt}\"" "$f" 2>/dev/null; then
					mt=$(file_mtime "$f")
					if [ "$mt" -gt "$last_ts" ] 2>/dev/null; then
						last_ts=$mt
						last=$(fmt_day "$mt")
					fi
				fi
			done < <(find "$root" -type f \( -name '*.jsonl' -o -name '*.json' -o -name '*.md' \) 2>/dev/null)
		done < "$roots"
	else
		last=unscanned
	fi
	recent=$([ "$last_ts" -gt 0 ] 2>/dev/null && [ $(( (now - last_ts) / 86400 )) -le 4 ] && echo yes || echo no)

	case "$dirty" in wip:*) bucket=hold-wip ;; *)
		case "$pr" in *OPEN*) bucket=hold-open-pr ;; *)
			if [ "$scan_ok" != yes ]; then bucket=review
			elif [ "$recent" = yes ]; then bucket=verify-recent-chat
			elif [ "$merged" = YES ] || [ "$pr" != "-" ]; then bucket=safe
			else bucket=review; fi ;;
		esac ;;
	esac

	printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
		"$size" "$age" "$merged" "$dirty" "$remote" "$pr" "$last" "$bucket" "$wt"
done | sort -t$'\t' -k1,1 -rh

rm -f "$prs" "$roots"
