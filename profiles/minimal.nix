{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/core.nix
    ../modules/nvim.nix
    ../modules/configs.nix
    ../modules/shell.nix
    ../modules/git.nix
  ];

  programs.git.userName  = "Fiqry Choerudin";
  programs.git.userEmail = "fiqrychoerudin48@gmail.com";
}
