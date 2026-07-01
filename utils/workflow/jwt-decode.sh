#!/usr/bin/env bash

set -euo pipefail
# inspiration for this https://gist.github.com/angelo-v/e0208a18d455e2e6ea3c40ad637aac53/revisions

decode_base64url() {
	local input="$1"
	input="${input//-/+}"
	input="${input//_/\/}"
	local mod=$((${#input} % 4))
	if [ "$mod" -eq 2 ]; then
		input+="=="
	elif [ "$mod" -eq 3 ]; then
		input+="="
	fi
	echo "$input" | base64 -d 2>/dev/null
}

if [ $# -ne 1 ]; then
	echo "Usage: $0 <jwt>" >&2
	exit 1
fi

jwt="$1"
IFS='.' read -r header payload signature <<<"$jwt"

if [ -z "${header:-}" ] || [ -z "${payload:-}" ]; then
	echo "Error: input doesn't look like a valid JWT (expected header.payload.signature)" >&2
	exit 1
fi

echo "== HEADER =="
decode_base64url "$header" | (command -v jq >/dev/null && jq . || cat)
echo
echo "== PAYLOAD =="
decode_base64url "$payload" | (command -v jq >/dev/null && jq . || cat)
echo
echo "== SIGNATURE (raw, base64url) =="
echo "$signature"
