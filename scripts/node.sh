#!/usr/bin/env bash
set -euo pipefail

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

# ── Load nvm (installed via Brewfile) ─────────────────────────────
NVM_SCRIPT="$BREW_PREFIX/opt/nvm/nvm.sh"
if [ -s "$NVM_SCRIPT" ]; then
  echo "==> Loading nvm from $NVM_SCRIPT..."
  \. "$NVM_SCRIPT"
else
  echo "WARNING: nvm.sh not found at $NVM_SCRIPT"
  echo "  BREW_PREFIX=$BREW_PREFIX"
  echo "  Contents of opt/nvm/: $(ls "$BREW_PREFIX/opt/nvm/" 2>&1 || echo 'directory not found')"
fi

# ── Install Node.js LTS ──────────────────────────────────────────
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

# ── Symlink node binaries for devcontainer exec ───────────────────
NVM_NODE_BIN="$(dirname "$(nvm which current)")"
echo "==> Symlinking node binaries into /usr/local/bin..."
$SUDO ln -sf "$NVM_NODE_BIN/"* /usr/local/bin/

# ── Add nvm init to shell rc files ───────────────────────────────
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
