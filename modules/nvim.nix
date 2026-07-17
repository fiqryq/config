{ config, pkgs, pkgs-unstable, lib, ... }:

{
  home.packages = [ pkgs-unstable.neovim ];

  # Symlink the LazyVim config from the dotfiles repo.
  # lazy.nvim writes lazy-lock.json back through this symlink into the repo — that's intentional.
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dot-config/config/nvim";
  };
}
