{
  lib,
  pkgs,
}: pkgs.vimUtils.buildVimPlugin {
    name = "sops-nvim";
    version = "0.0.1";

    src = with lib.fileset; toSource {
      root = ../.;
      fileset = unions [
        ../plugin
        ../editor.lua
        ../lua
      ];
    };

    meta = with lib; {
      description = "Encrypt/decrypt sops files directly from neovim";
      homepage = "https://git.lemarsu.com/neovim/sops.nvim";
      license = licenses.mit;
    };
  }
