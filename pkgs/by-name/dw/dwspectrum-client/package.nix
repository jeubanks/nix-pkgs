{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  xkeyboard_config,
  alsa-lib,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  libGL,
  libGLU,
  libpulseaudio,
  libsecret,
  libxkbcommon,
  qt6,
  nss,
  nspr,
  orc,
  openssl,
  libgudev,
  libxml2_13,
  libx11,
  libxcomposite,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  libxcb,
  libxcb-util,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  vulkan-loader,
  wayland,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "dwspectrum-client";
  version = "6.1.0.42176";

  src = fetchurl {
    url = "https://updates.digital-watchdog.com/digitalwatchdog/42176/linux/dwspectrum-client-6.1.0.42176-linux_x64.deb";
    hash = "sha256-ZuuzdBWxhqkg3bylI0h2dGYKhe3vCTkOB2P++XXpCMU=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    dbus
    expat
    fontconfig
    freetype
    glib
    libGL
    libGLU
    libpulseaudio
    libsecret
    libxkbcommon
    qt6.qt5compat
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtpositioning
    qt6.qtquick3d
    qt6.qtshadertools
    qt6.qtsvg
    qt6.qttools
    qt6.qtwayland
    qt6.qtwebchannel
    qt6.qtwebengine
    qt6.qtwebsockets
    qt6.qtwebview
    nss
    nspr
    orc
    openssl
    stdenv.cc.cc.lib
    libgudev
    (lib.getLib libxml2_13)
    libx11
    libxcomposite
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    wayland
    zlib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontWrapQtApps = true;

  runtimeLibraryPath = lib.makeLibraryPath [
    libGL
    libsecret
    stdenv.cc.cc.lib
    vulkan-loader
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt6WaylandEglClientHwIntegration.so.6"
    "libigdgmm.so.12"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r opt usr "$out"/

    mkdir -p "$out/bin"

    substituteInPlace "$out/usr/share/applications/dwspectrum.desktop" \
      --replace-fail "Exec=/opt/digitalwatchdog/client/${version}/bin/applauncher" "Exec=$out/bin/dwspectrum-client"
    substituteInPlace "$out/usr/share/applications/dw-vms.desktop" \
      --replace-fail "Exec=/opt/digitalwatchdog/client/${version}/bin/client %u" "Exec=$out/bin/dwspectrum-client %u"

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace "$out/opt/digitalwatchdog/client/${version}/bin/choose_newer_stdcpp.sh" \
      --replace-fail '    if command -v ldconfig >/dev/null 2>&1; then' '    if [ -f "${stdenv.cc.cc.lib}/lib/libstdc++.so.6" ]; then' \
      --replace-fail "        ldconfig -p | grep libstdc++.so.6 | head -n 1 | sed 's/.*=> //'" "        echo \"${stdenv.cc.cc.lib}/lib/libstdc++.so.6\""

    substituteInPlace "$out/opt/digitalwatchdog/client/${version}/bin/client" \
      --replace-fail "SYSTEM_OPENGL=\"\$(ldconfig -p | grep libOpenGL.so.0 | head -n 1 | sed 's/.*=> //')\"" "SYSTEM_OPENGL=\"${libGL}/lib/libOpenGL.so.0\""

    wrapProgram "$out/opt/digitalwatchdog/client/${version}/bin/client" \
      --prefix LD_LIBRARY_PATH : "${runtimeLibraryPath}" \
      --set QT_XKB_CONFIG_ROOT "${xkeyboard_config}/share/X11/xkb"

    ln -s "$out/opt/digitalwatchdog/client/${version}/bin/client" "$out/bin/dwspectrum-client"
  '';

  meta = with lib; {
    description = "DW Spectrum Client";
    homepage = "https://digital-watchdog.com";
    platforms = platforms.linux;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    license = licenses.unfree;
    mainProgram = "dwspectrum-client";
  };
}
