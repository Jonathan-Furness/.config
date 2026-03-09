# .config

My personal configuration files for development tools.

## What's included

- **Neovim** - Text editor configuration with plugins and keybindings
- **tmux** - Terminal multiplexer with Catppuccin theme and plugins
- **lazygit** - Terminal UI for git
- **opencode** - AI coding assistant
- **Zed** - Modern code editor settings and extensions
- **zsh** - Shell aliases

## Installation

Clone this repository and run one of the install scripts:

```bash
git clone https://github.com/Jonathan-Furness/.config.git ~/.config
cd ~/.config
```

### Standard (Homebrew / apt)

```bash
./install.sh
```

Installs via Homebrew (macOS) or apt + manual downloads (Linux). Lightweight and fast.

### Nix (reproducible, cross-platform)

```bash
./install-nix.sh
```

Installs via Nix + Home Manager. Same packages on any platform with pinned versions. Heavier (~1-2GB) but fully reproducible.

Both scripts will:
1. Install packages (neovim, tmux, lazygit, etc.)
2. Symlink/manage configs in `~/.config/`
3. Set up zsh with Oh My Zsh and plugins
4. Install TPM (tmux plugin manager)

After installation, open tmux and press `prefix + I` to install tmux plugins.

## Notes

These configurations are tailored to my workflow and preferences. Feel free to fork and modify them to suit your needs.
