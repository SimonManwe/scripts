#!/bin/bash
function fsb() {
	local pattern=$*
	local branches branch

	branches=$(git branch --all | awk 'tolower($0) ~ /'"$pattern"'/')

	if [ -z "$branches" ]; then
		echo "[$0] No branch matches the provided pattern"
		return 1
	fi

	branch=$(echo "$branches" | fzf-tmux -p --reverse -1 -0 +m)

	if [ -z "$branch" ]; then
		echo "[$0] No branch selected"
		return 1
	fi

	git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}
fsb "$@"
