#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting Nix-based dotfiles install..."

# ── Install Nix ────────────────────────────────────────────────────
if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix..."
  if [[ "$(uname)" == "Darwin" ]]; then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
  else
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
  fi

  # Load nix into current shell
  if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  elif [[ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi
else
  echo "==> Nix already installed"
fi

# ── Enable flakes ──────────────────────────────────────────────────
mkdir -p "$HOME/.config/nix"
if ! grep -qF 'experimental-features' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  echo "==> Enabling Nix flakes..."
  echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"
fi

# ── Apply Home Manager configuration ──────────────────────────────
SYSTEM="$(nix eval --impure --raw --expr 'builtins.currentSystem')"

echo "==> Applying Home Manager config for $SYSTEM..."
nix run home-manager -- switch --flake "$CONFIG_DIR#$SYSTEM" --impure

echo ""
echo "==> Done! Open tmux and press prefix + I to install tmux plugins."
