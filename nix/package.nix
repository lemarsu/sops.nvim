{
  lib,
  pkgs,
}: let
  inherit (builtins) baseNameOf filterSource;
  inherit (lib.strings) hasSuffix;
  filterOutNix = path: type:
    (type == "directory" && baseNameOf path != "nix")
    || type == "regular" && !(hasSuffix ".nix" path || baseNameOf path == "flake.lock");
in
  pkgs.vimUtils.buildVimPlugin {
    name = "sops-nvim";
    version = "0.0.1";

    src = filterSource filterOutNix ./..;

    meta = with lib; {
      description = "Encrypt/decrypt sops files directly from neovim";
      homepage = "https://git.lemarsu.com/neovim/sops.nvim";
      license = licenses.mit;
    };
  }
