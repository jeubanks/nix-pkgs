# dwspectrum-client

Package definition: [package.nix](package.nix)

## Runtime notes

- The upstream client bundle currently behaves as an X11/XWayland application on Wayland desktops.
- On `niri`, the client was verified to start once `XWayland-satellite` was available.
- The package wrapper intentionally uses the bundled Qt platform plugins to avoid mixing the bundled Qt 6.9 runtime with Nix Qt 6.10 plugins, which caused platform plugin initialization failures.

## Troubleshooting

- If the client fails on Wayland with `Could not load the Qt platform plugin "xcb"`, verify that an XWayland server is actually available to the session.
- On `niri`, `XWayland-satellite` is one working option.
- If startup still fails, check that `DISPLAY` is set in the environment that launches `dwspectrum-client`.
- For plugin diagnostics, run:

```bash
QT_DEBUG_PLUGINS=1 dwspectrum-client
```

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
