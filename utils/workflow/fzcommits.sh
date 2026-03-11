#!/bin/bash
function fshow() {
	local _gitlog

	_gitlog=(
		git log --graph --color=always
		--format="%C(auto)%h%d %s %C(black)%C(bold)%cr"
		"$@"
	)

	"${_gitlog[@]}" |
		fzf --ansi --no-sort --reverse --tiebreak=index \
			--bind="ctrl-s:toggle-sort" \
			--header="enter: toggle preview, ctrl-o: checkout, ctrl-f/b: scroll preview" \
			--preview="hash=\$(echo {} | sed 's/[^a-f0-9]*//' | grep -o '[a-f0-9]\{7,\}' | head -1); [ -n \"\$hash\" ] && git show --color=always \"\$hash\"" \
			--preview-window=right:60% \
			--bind="ctrl-f:preview-page-down,ctrl-b:preview-page-up" \
			--bind="ctrl-m:toggle-preview" \
			--bind="ctrl-o:become:(echo {} | sed 's/[^a-f0-9]*//' | grep -o '[a-f0-9]\{7,\}' | head -1 | xargs git checkout)"
}
fshow "$@"
