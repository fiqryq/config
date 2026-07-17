{ config, pkgs, lib, ... }:

# Installs a single pinned Node.js LTS version + pnpm via Nix.
# When this module is active, NVM is NOT loaded (shell.nix checks NIX_HM_NODE).
# Do NOT import this module in profiles that need NVM multi-version switching.

{
  home.packages = with pkgs; [
    nodejs_24
    pnpm
  ];

  home.sessionVariables = {
    PNPM_HOME   = "${config.home.homeDirectory}/Library/pnpm";
    NIX_HM_NODE = "1";
  };
}
