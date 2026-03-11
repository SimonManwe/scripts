#!/bin/bash
# Setup script for utility scripts repository
# Usage: ./setup.sh [path/to/scripts...]
# Example: ./setup.sh                        # sets up all scripts
#          ./setup.sh utils/workflow/fzcommits.sh        # sets up specific script
#          ./setup.sh utils/workflow                    # sets up all scripts in a dir

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/local/bin"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

install_script() {
	local script_path="$1"
	local script_name
	script_name=$(basename "$script_path" .sh)
	local link="$INSTALL_DIR/$script_name"

	# Skip non-executable/non-shell files
	if [[ "$script_path" != *.sh ]] && ! head -1 "$script_path" | grep -q "^#!"; then
		log_warning "Skipping $script_path (not a shell script)"
		return
	fi

	# Handle existing symlink or file
	if [ -L "$link" ]; then
		local current_target
		current_target=$(readlink "$link")
		if [ "$current_target" = "$script_path" ]; then
			log_warning "Already linked: $script_name"
			return
		else
			log_warning "Updating existing link: $script_name ($current_target → $script_path)"
			sudo rm "$link"
		fi
	elif [ -e "$link" ]; then
		log_error "Skipping $script_name — a non-symlink file already exists at $link"
		return
	fi

	chmod +x "$script_path"
	sudo ln -s "$script_path" "$link"
	log_success "Linked: $script_name → $link"
}

# Collect scripts to install
declare -a scripts

if [ $# -eq 0 ]; then
	# No args — recursively find all .sh files, excluding setup.sh itself
	while IFS= read -r -d '' file; do
		[[ "$(basename "$file")" == "setup.sh" ]] && continue
		scripts+=("$file")
	done < <(find "$REPO_DIR" -name "*.sh" -print0)
else
	# Args provided — resolve each to full path
	for arg in "$@"; do
		full_path="$REPO_DIR/$arg"
		if [ -f "$full_path" ]; then
			scripts+=("$full_path")
		elif [ -d "$full_path" ]; then
			while IFS= read -r -d '' file; do
				scripts+=("$file")
			done < <(find "$full_path" -name "*.sh" -print0)
		else
			log_error "Path not found: $arg"
		fi
	done
fi

if [ ${#scripts[@]} -eq 0 ]; then
	log_error "No scripts found to install"
	exit 1
fi

echo "Installing ${#scripts[@]} script(s) to $INSTALL_DIR..."
echo ""

for script in "${scripts[@]}"; do
	install_script "$script"
done

echo ""
echo "Done!"
