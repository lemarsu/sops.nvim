{
  imports = [
    ./sops-nvim.nix
  ];

  perSystem = {self', ...}: {
    packages.default = self'.packages.sops-nvim;
  };
}
