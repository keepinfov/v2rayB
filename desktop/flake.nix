{
  description = "v2rayB Desktop - Tauri wrapper for v2rayB service";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ rust-overlay.overlays.default ];
        pkgs = import nixpkgs { inherit system overlays; };

        rust = pkgs.rust-bin.stable.latest.default;

        libraries = with pkgs; [
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

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rust
            pkg-config
            cargo-tauri
          ] ++ libraries;

          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
            export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
            export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules/
            echo "v2rayB Desktop dev environment"
            echo "Run: cargo tauri dev"
          '';
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "v2rayb-desktop";
          version = "0.1.0";
          src = ./src-tauri;
          cargoLock.lockFile = ./src-tauri/Cargo.lock;

          nativeBuildInputs = with pkgs; [ pkg-config cargo-tauri ];
          buildInputs = libraries;

          buildPhase = ''
            cargo tauri build -b none
          '';

          installPhase = ''
            install -Dm755 target/release/v2rayb-desktop $out/bin/v2rayb-desktop
          '';

          meta = {
            description = "v2rayB Desktop wrapper";
            mainProgram = "v2rayb-desktop";
          };
        };
      }
    );
}
