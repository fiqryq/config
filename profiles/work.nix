{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/core.nix
    ../modules/nvim.nix
    ../modules/configs.nix
    ../modules/shell.nix
    ../modules/git.nix
    ../modules/fnm.nix
    ../modules/nginx.nix
    ../modules/devops.nix
    ../modules/ssh.nix
  ];

  programs.git.userName  = "Fiqry Choerudin";
  programs.git.userEmail = "fiqrychoerudin48@gmail.com";

  home.sessionVariables = {
    KUBECONFIG   = "$HOME/.kube/config";
    WORK_PROFILE = "1";
  };
}
