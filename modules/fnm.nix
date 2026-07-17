{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    pkgs.fnm
    # bun from unstable: 24.11's bun (1.1.x) never runs postinstall scripts
    # for global packages, which breaks stub-based CLIs like opencode
    pkgs-unstable.bun
    pkgs.yarn
  ];
}
