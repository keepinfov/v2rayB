{
  description = "v2rayB Desktop Client - Tauri-based desktop app";

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

        rust = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

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

        packages = with pkgs; [
          rust
          pkg-config
          cargo-tauri
          nodejs_22
          yarn
          dbus
          openssl
          glib
          gtk3
          libsoup_3
          webkitgtk_4_1
          librsvg
          gsettings-desktop-schemas
          glib-networking
        ];

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = packages;

          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
            export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
            export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules/
            export WEBKIT_DISABLE_COMPOSITING_MODE=1
            echo "v2rayB Desktop development environment loaded"
            echo "Run 'yarn install' then 'yarn tauri dev' to start development"
          '';
        };

        packages.default = pkgs.callPackage ./package.nix {
          inherit (pkgs)
            lib stdenv rustPlatform fetchYarnDeps symlinkJoin
            yarnConfigHook yarnBuildHook nodejs yarn
            pkg-config makeWrapper cargo-tauri
            webkitgtk_4_1 gtk3 cairo gdk-pixbuf glib dbus openssl librsvg libsoup_3;
        };
      }
    );
}
