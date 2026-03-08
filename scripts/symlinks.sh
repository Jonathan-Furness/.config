#!/usr/bin/env bash
set -euo pipefail

link_config() {
  local src="$1"
  local dest="$2"

  if [[ "$src" == "$dest" ]]; then
    echo "    Skipping $dest (same location)"
    return
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "    Backing up $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  if [[ -L "$dest" ]]; then
    rm "$dest"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "    Linked $dest -> $src"
}

if [[ "$SCRIPT_DIR" != "$CONFIG_DIR" ]]; then
  echo "==> Symlinking configs into $CONFIG_DIR..."
  link_config "$SCRIPT_DIR/nvim"              "$CONFIG_DIR/nvim"
  link_config "$SCRIPT_DIR/tmux"              "$CONFIG_DIR/tmux"
  link_config "$SCRIPT_DIR/lazygit"           "$CONFIG_DIR/lazygit"
  link_config "$SCRIPT_DIR/zsh"              "$CONFIG_DIR/zsh"
  link_config "$SCRIPT_DIR/starship.toml"    "$CONFIG_DIR/starship.toml"
  link_config "$SCRIPT_DIR/zed"              "$CONFIG_DIR/zed"
  link_config "$SCRIPT_DIR/devcontainer"     "$CONFIG_DIR/devcontainer"
  link_config "$SCRIPT_DIR/scripts"          "$CONFIG_DIR/scripts"
else
  echo "==> Repo is already at $CONFIG_DIR — no symlinks needed"
fi
