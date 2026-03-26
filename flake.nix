{
  description = "codecompanion-ui devShell, formatting, and linting checks";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmt-eval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        treefmt-wrapper = treefmt-eval.config.build.wrapper;
      in
      {
        formatter = treefmt-wrapper;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            selene
            treefmt-wrapper
          ];
        };
        checks = {
          formatting = treefmt-eval.config.build.check self;
          selene = pkgs.callPackage (import ./checks/selene.nix) { inherit self pkgs; };
        };
      }
    );
}
