{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        luaPackages.luacheck
        nil
        sumneko-lua-language-server
      ];
    };
  };
}
