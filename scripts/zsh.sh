#!/usr/bin/env bash
set -euo pipefail

# ── Install zsh ───────────────────────────────────────────────────
if ! command -v zsh &>/dev/null; then
  echo "==> Installing zsh..."
  if command -v apt-get &>/dev/null; then
    $SUDO apt-get update && $SUDO apt-get install -y zsh
  else
    brew install zsh
  fi
fi

# ── Set zsh as default shell ──────────────────────────────────────
ZSH_PATH="$(command -v zsh)"
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
  echo "==> Setting zsh as default shell..."
  if ! grep -qF "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "$ZSH_PATH" | $SUDO tee -a /etc/shells >/dev/null
  fi
  $SUDO chsh -s "$ZSH_PATH" "$(whoami)"
else
  echo "==> zsh is already the default shell"
fi

# ── Install Oh My Zsh ────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "==> Oh My Zsh already installed"
fi

# ── Install zsh autocompletion plugins ────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo "==> Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
  echo "==> Installing zsh-completions..."
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# ── Configure .zshrc ──────────────────────────────────────────────
# Oh My Zsh plugins
if grep -q '^plugins=' "$HOME/.zshrc" 2>/dev/null; then
  if ! grep -q 'zsh-autosuggestions' "$HOME/.zshrc" 2>/dev/null; then
    echo "==> Updating Oh My Zsh plugins..."
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' "$HOME/.zshrc"
  fi
else
  echo "==> Adding Oh My Zsh plugins to .zshrc..."
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' >> "$HOME/.zshrc"
fi

# Source aliases
ALIAS_SOURCE='[[ -f ~/.config/zsh/.aliases ]] && source ~/.config/zsh/.aliases'
if ! grep -qF "$ALIAS_SOURCE" "$HOME/.zshrc" 2>/dev/null; then
  echo "==> Adding alias sourcing to ~/.zshrc..."
  echo "" >> "$HOME/.zshrc"
  echo "# Dotfiles aliases" >> "$HOME/.zshrc"
  echo "$ALIAS_SOURCE" >> "$HOME/.zshrc"
else
  echo "==> Aliases already sourced in ~/.zshrc"
fi

# Starship prompt
if ! grep -qF 'starship init' "$HOME/.zshrc" 2>/dev/null; then
  echo "==> Adding starship init to .zshrc..."
  echo "" >> "$HOME/.zshrc"
  echo '# Starship prompt' >> "$HOME/.zshrc"
  echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
else
  echo "==> Starship already configured in .zshrc"
fi
