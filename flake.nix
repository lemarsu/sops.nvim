{
  description = "Jolly Jumper - TUI file manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    alejandra,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = import ./nix/shell.nix {
          inherit nixpkgs system;
        };

        formatter = alejandra.defaultPackage.${system};

        packages = rec {
          default = sops-nvim;
          sops-nvim = pkgs.callPackage ./nix/package.nix {};
        };
      }
    );
}
