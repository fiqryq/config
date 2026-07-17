{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kubernetes-helm
    google-cloud-sdk
    mkcert
    sops
    k9s
  ];

  programs.zsh.initExtra = lib.mkAfter ''
    # kubectl completions
    if command -v kubectl &>/dev/null; then
      source <(kubectl completion zsh)
    fi
    # helm completions
    if command -v helm &>/dev/null; then
      source <(helm completion zsh)
    fi
  '';
}
