{ config, pkgs, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dot-config";
in
{
  home.packages = with pkgs; [ mkcert ];

  # Live symlink → writable, so nginx-add writes .conf files here
  # and they stay tracked in the dotfiles repo
  xdg.configFile."nginx/servers".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nginx/servers";

  home.file.".local/bin/nginx-add" = {
    source = ../config/nginx/nginx-add;
    executable = true;
  };

  home.file.".local/bin/nginx-remove" = {
    source = ../config/nginx/nginx-remove;
    executable = true;
  };
}
