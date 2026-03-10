# nix-pkgs

Multi-package Nix repository using a `pkgs/by-name` layout aligned with upstream nixpkgs conventions.

## Repository structure

- Package set loader: [pkgs/default.nix](pkgs/default.nix)
- Packages root: [pkgs/by-name](pkgs/by-name)
- Current package: [pkgs/by-name/dw/dwspectrum-client](pkgs/by-name/dw/dwspectrum-client)
- Flake entrypoint: [flake.nix](flake.nix)
- Legacy default package entrypoint: [default.nix](default.nix)

## Build packages

- Build a specific package:

```bash
nix build path:.#dwspectrum-client --impure
```

- Build the default package:

```bash
nix build path:.#default --impure
```

## Install (user profile)

- Install into your user profile:

```bash
nix profile install path:.#dwspectrum-client --impure
```

- Run after install:

```bash
dwspectrum-client
```

- Uninstall from your profile:

```bash
nix profile remove dwspectrum-client
```

## Install (NixOS system-wide)

- Flake-based configuration:

```nix
{
  inputs.nix-pkgs.url = "path:/home/john/github/nix-pkgs";

  outputs = { self, nixpkgs, nix-pkgs, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            nix-pkgs.packages.${pkgs.system}.dwspectrum-client
          ];
        })
      ];
    };
  };
}
```

- Non-flake `configuration.nix`:

```nix
{ config, pkgs, ... }:

let
  localPkgs = import /home/john/github/nix-pkgs/pkgs { inherit pkgs; };
in {
  environment.systemPackages = [
    localPkgs.dwspectrum-client
  ];
}
```

## dwspectrum-client maintenance

See package-local documentation at [pkgs/by-name/dw/dwspectrum-client/README.md](pkgs/by-name/dw/dwspectrum-client/README.md).

Common commands:

```bash
./pkgs/by-name/dw/dwspectrum-client/update.sh '<deb-url>' --build
./pkgs/by-name/dw/dwspectrum-client/discover-latest.sh --apply --build
```
