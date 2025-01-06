{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) lib;
  in {
    packages.sops-nvim = pkgs.vimUtils.buildVimPlugin {
      name = "sops-nvim";
      version = "0.0.1";
      nvimRequireCheck = "sops";

      src = with lib.fileset;
        toSource {
          root = ../..;
          fileset = unions [
            ../../plugin
            ../../editor.lua
            ../../lua
          ];
        };

      meta = with lib; {
        description = "Encrypt/decrypt sops files directly from neovim";
        homepage = "https://git.lemarsu.com/neovim/sops.nvim";
        license = licenses.mit;
      };
    };
  };
}
