{
  nixpkgs,
  system,
}: let
  pkgs = import nixpkgs {
    inherit system;
  };
in
  with pkgs;
    mkShell {
      nativeBuildInputs = [];
      buildInputs = [
        luaPackages.luacheck
        nil
        sumneko-lua-language-server
      ];
    }
