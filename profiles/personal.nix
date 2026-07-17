{ config, pkgs, lib, ... }:

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

  programs.git.userName  = "Fiqry Choerudin";
  programs.git.userEmail = "fiqrychoerudin48@gmail.com";
}
