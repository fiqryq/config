{
  description = "fiqrychoerudin home-manager dotfiles — multi-profile";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system      = "aarch64-darwin";
      pkgs        = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

      mkProfile = import ./lib/mkProfile.nix {
        inherit system home-manager pkgs pkgs-unstable;
        username      = "fiqrychoerudin";
        homeDirectory = "/Users/fiqrychoerudin";
      };
    in
    {
      # Switch with:  home-manager switch --flake ~/dot-config#<name>
      # Or use the `hms` shell function defined in modules/shell.nix
      homeConfigurations = {
        personal = mkProfile ./profiles/personal.nix;
        work     = mkProfile ./profiles/work.nix;
        minimal  = mkProfile ./profiles/minimal.nix;
        neurona  = mkProfile ./profiles/neurona.nix;
      };
    };
}
