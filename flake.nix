{
  description = "v2rayB - v2rayA fork with custom web UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        version = "2.0.0";

        v2rayb = pkgs.buildGoModule {
          pname = "v2rayb";
          inherit version;
          src = ./.;
          vendorHash = "sha256-uiURsB1V4IB77YKLu5gdaqw9Fuja6fC5adWYDE3OE+Q=";

          modRoot = "./service";
          doCheck = false;

          postUnpack = ''
            mkdir -p $sourceRoot/service/server/router/web
            cp -r $sourceRoot/web/* $sourceRoot/service/server/router/web/
          '';

          ldflags = [
            "-s" "-w"
            "-X github.com/v2rayA/v2rayA/conf.Version=${version}"
          ];

          meta = {
            description = "v2rayB service with embedded web UI";
            mainProgram = "v2rayA";
          };
        };

        desktopLibs = with pkgs; [
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

        v2rayb-desktop = pkgs.rustPlatform.buildRustPackage {
          pname = "v2rayb-desktop";
          inherit version;
          src = ./desktop/src-tauri;
          cargoLock.lockFile = ./desktop/src-tauri/Cargo.lock;

          nativeBuildInputs = with pkgs; [ pkg-config ];
          buildInputs = desktopLibs;

          postInstall = ''
            mv $out/bin/v2rayb-desktop $out/bin/v2rayb-desktop || true
          '';

          meta = {
            description = "v2rayB Desktop wrapper";
            mainProgram = "v2rayb-desktop";
          };
        };

      in {
        packages = {
          default = v2rayb;
          inherit v2rayb v2rayb-desktop;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ go nodejs yarn cargo rustc pkg-config ] ++ desktopLibs;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath desktopLibs;
        };
      }
    ) // {
      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.v2rayb;
        in {
          options.services.v2rayb = {
            enable = lib.mkEnableOption "v2rayB service";

            address = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1:50541";
              description = "Listen address";
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.system}.v2rayb;
            };
          };

          config = lib.mkIf cfg.enable {
            systemd.services.v2rayb = {
              description = "v2rayB Service";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                ExecStart = "${cfg.package}/bin/v2rayA --address ${cfg.address}";
                Restart = "on-failure";
                AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW";
              };
            };
          };
        };
    };
}
