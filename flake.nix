{
  description = "DW Spectrum Client package from upstream deb";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f (import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          })
        );
    in {
      packages = forAllSystems (pkgs:
        let
          packageSet = import ./pkgs { inherit pkgs; };
        in
          packageSet // {
            default = packageSet.dwspectrum-client;
          }
      );
    };
}
