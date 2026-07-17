{ config, pkgs, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dot-config/config";
in
{
  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/ghostty";

  xdg.configFile."tmux".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/tmux";

  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wezterm";
}
