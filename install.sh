#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Use sudo if available, otherwise run directly (e.g. already root in container)
if command -v sudo &>/dev/null; then
  SUDO="sudo"
else
  SUDO=""
fi

echo "==> Starting dotfiles install..."

# ── 0. Install system build tools ─────────────────────────────────
if command -v apt-get &>/dev/null; then
  echo "==> Installing build-essential via apt..."
  $SUDO apt-get update && $SUDO apt-get install -y build-essential
fi

# ── 1. Install Homebrew ──────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the rest of this script
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "==> Homebrew already installed"
fi

# ── 2. Install packages via Brewfile ─────────────────────────────────
echo "==> Installing packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

# ── 3. Symlink configs ──────────────────────────────────────────────
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
  link_config "$SCRIPT_DIR/opencode"          "$CONFIG_DIR/opencode"
  link_config "$SCRIPT_DIR/zsh"               "$CONFIG_DIR/zsh"
else
  echo "==> Repo is already at $CONFIG_DIR — no symlinks needed"
fi

# ── 4. Set up zsh ───────────────────────────────────────────────────
if ! command -v zsh &>/dev/null; then
  echo "==> Installing zsh..."
  if command -v apt-get &>/dev/null; then
    $SUDO apt-get update && $SUDO apt-get install -y zsh
  else
    brew install zsh
  fi
fi

# Set zsh as default shell
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

# Ensure brew shellenv is sourced in .zshrc
BREW_SHELLENV=""
if [[ -f /opt/homebrew/bin/brew ]]; then
  BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
elif [[ -f /usr/local/bin/brew ]]; then
  BREW_SHELLENV='eval "$(/usr/local/bin/brew shellenv)"'
fi

add_brew_to_rc() {
  local rc_file="$1"
  if [[ -n "$BREW_SHELLENV" ]] && ! grep -qF "brew shellenv" "$rc_file" 2>/dev/null; then
    echo "==> Adding Homebrew to PATH in $rc_file..."
    echo "" >> "$rc_file"
    echo "# Homebrew" >> "$rc_file"
    echo "$BREW_SHELLENV" >> "$rc_file"
  else
    echo "==> Homebrew PATH already in $rc_file"
  fi
}

add_brew_to_rc "$HOME/.profile"
add_brew_to_rc "$HOME/.zshrc"
add_brew_to_rc "$HOME/.bashrc"

# Ensure brew binaries are available in all contexts (including devcontainer exec)
BREW_PREFIX="$(brew --prefix)"
echo "==> Symlinking brew packages into /usr/local/bin..."
$SUDO mkdir -p /usr/local/bin
$SUDO ln -sf "$BREW_PREFIX/bin/"* /usr/local/bin/

# Also ensure /usr/local/bin is on the default PATH via /etc/profile.d
# (devcontainer exec with login shell will source this)
$SUDO mkdir -p /etc/profile.d
echo 'export PATH="/usr/local/bin:$PATH"' | $SUDO tee /etc/profile.d/brew-path.sh >/dev/null
$SUDO chmod +x /etc/profile.d/brew-path.sh

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

# ── 5. Set up nvm and Node.js LTS ────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

# Load nvm (installed via Brewfile)
NVM_SCRIPT="$BREW_PREFIX/opt/nvm/nvm.sh"
if [ -s "$NVM_SCRIPT" ]; then
  echo "==> Loading nvm from $NVM_SCRIPT..."
  \. "$NVM_SCRIPT"
else
  echo "WARNING: nvm.sh not found at $NVM_SCRIPT"
  echo "  BREW_PREFIX=$BREW_PREFIX"
  echo "  Contents of opt/nvm/: $(ls "$BREW_PREFIX/opt/nvm/" 2>&1 || echo 'directory not found')"
fi

# Install Node.js LTS
if command -v nvm &>/dev/null; then
  if ! command -v node &>/dev/null; then
    echo "==> Installing Node.js LTS..."
    nvm install --lts
  else
    echo "==> Node.js already installed ($(node --version))"
  fi
else
  echo "ERROR: nvm command not available — skipping Node.js install"
fi

# Symlink node binaries into /usr/local/bin for devcontainer exec
NVM_NODE_BIN="$(dirname "$(nvm which current)")"
echo "==> Symlinking node binaries into /usr/local/bin..."
$SUDO ln -sf "$NVM_NODE_BIN/"* /usr/local/bin/

# Add nvm init to shell rc files
NVM_INIT="export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"$BREW_PREFIX/opt/nvm/nvm.sh\" ] && \\. \"$BREW_PREFIX/opt/nvm/nvm.sh\""

for rc_file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
  if ! grep -qF 'NVM_DIR' "$rc_file" 2>/dev/null; then
    echo "==> Adding nvm to $rc_file..."
    echo "" >> "$rc_file"
    echo "# nvm" >> "$rc_file"
    echo "$NVM_INIT" >> "$rc_file"
  fi
done

# ── 6. Install TPM (Tmux Plugin Manager) ────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  echo "==> Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "==> TPM already installed"
fi

echo ""
echo "==> Done! Open tmux and press prefix + I to install tmux plugins."
