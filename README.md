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

Clone this repository and run the install script:

```bash
git clone https://github.com/Jonathan-Furness/.config.git ~/.config
cd ~/.config
./install.sh
```

The install script will:
1. Install Homebrew (if not present)
2. Install packages from the Brewfile (neovim, tmux, lazygit, opencode)
3. Symlink configs into `~/.config/` (if cloned elsewhere)
4. Set up zsh with aliases
5. Install TPM (tmux plugin manager)

After installation, open tmux and press `prefix + I` to install tmux plugins.

## Notes

These configurations are tailored to my workflow and preferences. Feel free to fork and modify them to suit your needs.
