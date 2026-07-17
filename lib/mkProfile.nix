{ system, home-manager, pkgs, pkgs-unstable, username, homeDirectory }:
profileModule:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    {
      home = {
        inherit username homeDirectory;
        # Pins the HM schema version — do NOT change without reading HM release notes
        stateVersion = "24.11";
      };

      nixpkgs.config.allowUnfree = true;

      # Make pkgs-unstable available to all modules via special args
      _module.args.pkgs-unstable = pkgs-unstable;
    }

    profileModule
  ];
}
