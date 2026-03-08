#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Linux packages..."

# ── apt packages ──────────────────────────────────────────────────
echo "==> Installing packages via apt..."
$SUDO apt-get update
$SUDO apt-get install -y \
  build-essential \
  curl \
  git \
  fd-find \
  ripgrep \
  fzf \
  tmux

# fd-find installs as fdfind — symlink to fd
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  echo "==> Symlinking fdfind → fd"
  $SUDO ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

# ── GitHub CLI (gh) ───────────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  echo "==> Installing GitHub CLI..."
  $SUDO mkdir -p /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $SUDO tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  $SUDO chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  $SUDO apt-get update
  $SUDO apt-get install -y gh
else
  echo "==> GitHub CLI already installed ($(gh --version | head -1))"
fi

# ── Neovim (latest stable from GitHub releases) ──────────────────
if ! command -v nvim &>/dev/null; then
  echo "==> Installing Neovim..."
  NVIM_VERSION=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  NVIM_ARCH="$(uname -m)"  # x86_64 or aarch64
  [[ "$NVIM_ARCH" == "aarch64" ]] && NVIM_ARCH="arm64"
  curl -fsSL -o /tmp/nvim-linux.tar.gz "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz"
  tar xzf /tmp/nvim-linux.tar.gz -C /tmp
  $SUDO cp -r /tmp/nvim-linux-${NVIM_ARCH}/* /usr/local/
  rm -rf /tmp/nvim-linux-${NVIM_ARCH} /tmp/nvim-linux.tar.gz
else
  echo "==> Neovim already installed ($(nvim --version | head -1))"
fi

# ── Starship prompt ──────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
  echo "==> Installing Starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
else
  echo "==> Starship already installed ($(starship --version))"
fi

# ── Lazygit ──────────────────────────────────────────────────────
if ! command -v lazygit &>/dev/null; then
  echo "==> Installing Lazygit..."
  LAZYGIT_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -fsSL -o /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xzf /tmp/lazygit.tar.gz -C /tmp lazygit
  $SUDO install /tmp/lazygit /usr/local/bin/lazygit
  rm -f /tmp/lazygit /tmp/lazygit.tar.gz
else
  echo "==> Lazygit already installed ($(lazygit --version | head -1))"
fi

# ── nvm + Node.js ────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "==> Installing nvm..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Load nvm
\. "$NVM_DIR/nvm.sh"

if ! command -v node &>/dev/null; then
  echo "==> Installing Node.js LTS..."
  nvm install --lts
else
  echo "==> Node.js already installed ($(node --version))"
fi

# ── Add nvm init to shell rc files ───────────────────────────────
NVM_INIT='export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'

for rc_file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
  if ! grep -qF 'NVM_DIR' "$rc_file" 2>/dev/null; then
    echo "==> Adding nvm to $rc_file..."
    echo "" >> "$rc_file"
    echo "# nvm" >> "$rc_file"
    echo "$NVM_INIT" >> "$rc_file"
  fi
done

echo "==> Linux packages installed successfully"
