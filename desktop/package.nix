{
  lib,
  stdenv,
  rustPlatform,
  fetchYarnDeps,
  symlinkJoin,

  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  yarn,

  pkg-config,
  makeWrapper,
  cargo-tauri,

  webkitgtk_4_1,
  gtk3,
  cairo,
  gdk-pixbuf,
  glib,
  dbus,
  openssl,
  librsvg,
  libsoup_3,
}:
let
  pname = "v2rayb-desktop";
  version = "0.1.0";

  src = ../..;

  web = stdenv.mkDerivation {
    pname = "${pname}-web";
    inherit version src;

    sourceRoot = "${src.name}/gui";

    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/gui/yarn.lock";
      hash = "sha256-0000000000000000000000000000000000000000000=";  # Update after first build
    };

    env.OUTPUT_DIR = placeholder "out";

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      nodejs
    ];
  };

in
rustPlatform.buildRustPackage {
  inherit pname version;
  src = ../.;
  sourceRoot = "desktop/src-tauri";

  cargoLock.lockFile = ./src-tauri/Cargo.lock;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    cargo-tauri
    nodejs
    yarn
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    cairo
    gdk-pixbuf
    glib
    dbus
    openssl
    librsvg
    libsoup_3
  ];

  preBuild = ''
    cp -a ${web} ../gui/dist
  '';

  buildPhase = ''
    runHook preBuild
    cargo tauri build --bundles deb,appimage
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 target/release/v2rayb-desktop $out/bin/v2rayb-desktop
    install -Dm644 target/release/bundle/deb/*/data/usr/share/applications/*.desktop $out/share/applications/v2rayb.desktop
    install -Dm644 ../src-tauri/icons/128x128.png $out/share/icons/hicolor/128x128/apps/v2rayb.png
    runHook postInstall
  '';

  meta = {
    description = "v2rayB Desktop Client - Tauri-based desktop wrapper for v2rayB web GUI";
    homepage = "https://github.com/keepinfov/v2rayB";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "v2rayb-desktop";
  };
}
