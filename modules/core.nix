{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    tmux
    wezterm
    lazygit
    yazi
    carapace
    ripgrep
    fd
    jq
    tree
    wget
    curl
    python3
    python3Packages.pip
    pipx
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      pager = "less -FR";
    };
  };

  programs.eza = {
    enable = true;
    icons  = "auto";
  };

  programs.fzf = {
    enable                = true;
    enableZshIntegration  = true;
    defaultOptions = [
      "--preview 'bat --style=numbers --color=always {}'"
    ];
  };

  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable               = true;
    enableZshIntegration = true;
    nix-direnv.enable    = true;
  };

  programs.starship = {
    enable               = true;
    enableZshIntegration = true;
  };
}
