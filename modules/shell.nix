{ config, pkgs, lib, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER  = "less";
  };

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/Library/pnpm"
    "$HOME/.bun/bin"
    "$HOME/.cache/lm-studio/bin"
    "$HOME/.nix-profile/bin"
  ];

  # Seed ~/.env.local from the placeholder template on a fresh machine;
  # never touches an existing file (it holds real secrets, kept out of git)
  home.activation.seedEnvLocal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.env.local" ]; then
      install -m 600 ${../templates/env.local.example} "$HOME/.env.local"
      echo "Seeded ~/.env.local from template — fill in your secrets"
    fi
  '';

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable  = true;
      theme   = "robbyrussell";
      plugins = [ "git" ];
    };

    shellAliases = {
      # Editor
      vi      = "nvim";
      # Bat
      cat     = "bat";
      # Lazydocker
      ld      = "lazydocker";
      # Eza
      ls      = "eza --icons --group-directories-first";
      ll      = "eza --icons --group-directories-first -lah";
      ltree   = "eza --tree --level=2 --icons --git";
      # Shell
      reload  = "source ~/.zshrc";
      # FZF
      ff      = "fzf --style minimal --preview 'bat --style=numbers --color=always {}' --bind 'focus:transform-header:file --brief {}'";
      # Config shortcuts
      ecnvm   = "cd ~/.config/nvim && nvim .";
      enablehud  = "/bin/launchctl setenv MTL_HUD_ENABLED 1";
      disablehud = "/bin/launchctl setenv MTL_HUD_ENABLED 0";
      # Git
      gc      = "git commit -m";
      gca     = "git commit -a -m";
      gp      = "git push origin HEAD";
      gpu     = "git pull origin";
      gst     = "git status";
      gdiff   = "git diff";
      gco     = "git checkout";
      gb      = "git branch";
      gba     = "git branch -a";
      gadd    = "git add";
      ga      = "git add -p";
      gcoall  = "git checkout -- .";
      gr      = "git remote";
      gre     = "git reset";

      # Claude
      ai      = "claude";
    };

    initExtra = ''
      # Ensure Nix-managed binaries come first on PATH
      export PATH="$HOME/.nix-profile/bin:$HOME/.bun/bin:$PATH"

      # Carapace shell completions
      zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
      source <(carapace _carapace)
      carapace --style 'carapace.Value=bold,magenta'

      # Docker CLI completions (OrbStack)
      if [[ -d "$HOME/.docker/completions" ]]; then
        fpath=($HOME/.docker/completions $fpath)
      fi

      # fnm — fast Node version manager with auto-switching
      if command -v fnm &>/dev/null; then
        eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
      fi

      # EDITOR / .env.local
      if [[ -z $SSH_CONNECTION ]]; then
        [[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"
      fi

      # Start tmux on interactive shell start
      if command -v tmux &>/dev/null && [[ -z "$TMUX" ]]; then
        # Clean up stale socket if the server is no longer running
        local _tmux_socket="/tmp/tmux-$(id -u)/default"
        if [[ -S "$_tmux_socket" ]] && ! tmux list-sessions &>/dev/null 2>&1; then
          rm -f "$_tmux_socket"
        fi
        tmux attach -t default || tmux new -s default
      fi

      # Kiro IDE shell integration
      [[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

      # gwho — show which git identity / github account is active here
      function gwho() {
        echo "profile   : ''${NIX_HM_PROFILE:-unknown}"
        if git rev-parse --is-inside-work-tree &>/dev/null; then
          echo "commit as : $(git config user.name) <$(git config user.email)>"
          echo "push to   : $(git remote get-url origin 2>/dev/null || echo '(no remote)')"
        else
          echo "commit as : $(git config --global user.name) <$(git config --global user.email)> (global — not in a repo)"
        fi
      }

      # Profile switcher — hms <profile>
      function hms() {
        local profile="''${1:-personal}"
        local flake_dir="$HOME/dot-config"
        local valid_profiles=(personal work minimal neurona)

        if [[ ! " ''${valid_profiles[*]} " =~ " ''${profile} " ]]; then
          echo "Unknown profile: $profile"
          echo "Available: ''${valid_profiles[*]}"
          return 1
        fi

        echo "Switching to profile: $profile"
        echo "$profile" > "$HOME/.nix-current-profile"
        local hm_cmd
        if command -v home-manager &>/dev/null; then
          hm_cmd="home-manager"
        else
          hm_cmd="nix run github:nix-community/home-manager/release-24.11 --"
        fi
        ''${=hm_cmd} switch --flake "''${flake_dir}#''${profile}" "''${@:2}"
        exec zsh
      }

      # zsh completions for hms
      _hms_completions() {
        local profiles=(personal work minimal neurona)
        _describe 'profile' profiles
      }
      compdef _hms_completions hms

      # Show active profile in prompt area
      if [[ -f "$HOME/.nix-current-profile" ]]; then
        export NIX_HM_PROFILE="$(cat "$HOME/.nix-current-profile")"
      fi
    '';
  };
}
