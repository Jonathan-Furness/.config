#!/usr/bin/env bash
set -euo pipefail

export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CONFIG_DIR="$HOME/.config"

# Use sudo if available, otherwise run directly (e.g. already root in container)
if command -v sudo &>/dev/null; then
  export SUDO="sudo"
else
  export SUDO=""
fi

echo "==> Starting dotfiles install..."

if [[ "$(uname)" == "Darwin" ]]; then
  source "$SCRIPT_DIR/scripts/brew.sh"
  source "$SCRIPT_DIR/scripts/node.sh"
else
  source "$SCRIPT_DIR/scripts/linux-packages.sh"
fi

source "$SCRIPT_DIR/scripts/symlinks.sh"
source "$SCRIPT_DIR/scripts/zsh.sh"
source "$SCRIPT_DIR/scripts/tmux.sh"

echo ""
echo "==> Done! Open tmux and press prefix + I to install tmux plugins."
