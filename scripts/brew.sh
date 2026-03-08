#!/usr/bin/env bash
set -euo pipefail

# ── Install Homebrew ──────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the rest of this script
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "==> Homebrew already installed"
fi

# ── Install packages via Brewfile ─────────────────────────────────
echo "==> Installing packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

BREW_PREFIX="$(brew --prefix)"
export BREW_PREFIX
