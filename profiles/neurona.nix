{ config, pkgs, lib, ... }:

# Same package set as personal.nix, but with its own GitHub identity.
{
  imports = [
    ../modules/core.nix
    ../modules/nvim.nix
    ../modules/configs.nix
    ../modules/shell.nix
    ../modules/git.nix
    ../modules/fnm.nix
    ../modules/php.nix
    ../modules/nginx.nix
    ../modules/extras.nix
    ../modules/ssh.nix
  ];

  programs.git.userName  = "Neurona Frontend";
  programs.git.userEmail = "neuronafrontend@gmail.com";

  # Sign with the on-disk neurona key instead of 1Password (git.nix default).
  # Generate it with:
  #   ssh-keygen -t ed25519 -C "neuronafrontend@gmail.com" -f ~/.ssh/neurona_github
  # and register the .pub on GitHub as both Authentication and Signing key.
  programs.git.extraConfig = {
    user.signingkey = lib.mkForce "${config.home.homeDirectory}/.ssh/neurona_github";
    "gpg \"ssh\"".program = lib.mkForce "ssh-keygen";
  };
}
