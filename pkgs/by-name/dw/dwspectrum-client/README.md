# dwspectrum-client

Package definition: [package.nix](package.nix)

## Update package source

- Update directly from a known URL:

```bash
./pkgs/by-name/dw/dwspectrum-client/update.sh 'https://updates.digital-watchdog.com/digitalwatchdog/<build>/linux/dwspectrum-client-<version>-linux_x64.deb' --build
```

- Discover latest available URL first:

```bash
./pkgs/by-name/dw/dwspectrum-client/discover-latest.sh
./pkgs/by-name/dw/dwspectrum-client/discover-latest.sh --include-rc
./pkgs/by-name/dw/dwspectrum-client/discover-latest.sh --apply --build
```
