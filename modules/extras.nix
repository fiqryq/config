{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    ollama
    lazydocker
    lazysql
    cloudflared
  ];
}
