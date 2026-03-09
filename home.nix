{ pkgs, username, homeDir, ... }:

{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # ── CLI tools ────────────────────────────────────────────────────
  home.packages = with pkgs; [
    fd
    ripgrep
    fzf
    gh
    neovim
    starship
    tmux
    lazygit
    nodejs # needed for Mason LSP servers in LazyVim
  ];

  # ── Dotfile symlinks ─────────────────────────────────────────────
  xdg.configFile = {
    "nvim".source = ./nvim;
    "tmux".source = ./tmux;
    "lazygit".source = ./lazygit;
    "starship.toml".source = ./starship.toml;
    "zsh".source = ./zsh;
    "zed".source = ./zed;
    "devcontainer".source = ./devcontainer;
    "scripts".source = ./scripts;
  };

  # ── Zsh ──────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    initExtra = ''
      # Dotfiles aliases
      [[ -f ~/.config/zsh/.aliases ]] && source ~/.config/zsh/.aliases

      # Starship prompt
      eval "$(starship init zsh)"
    '';
  };

  # ── Tmux ─────────────────────────────────────────────────────────
  # TPM is managed via home.file rather than programs.tmux,
  # so your existing tmux.conf stays as-is
  home.file.".tmux/plugins/tpm" = {
    source = builtins.fetchGit {
      url = "https://github.com/tmux-plugins/tpm";
      rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
    };
  };
}
