{
  description = "v2rayB - v2rayA fork with Material Design 3 UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        version = "2.2.9";

        gui = pkgs.buildNpmPackage {
          pname = "v2rayb-gui";
          inherit version;
          src = ./ngui;

          npmDepsHash = "sha256-dcv6f6oQwqJ0PwS8I9jyHljmVGxce2u9K0BMbzWscpM=";

          npmFlags = [ "--legacy-peer-deps" ];

          buildPhase = ''
            runHook preBuild
            export NUXT_TELEMETRY_DISABLED=1
            export CI=1
            export TERM=dumb
            npm run generate
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r .output/public/* $out/
            runHook postInstall
          '';

          meta = {
            description = "v2rayB web GUI (Material Design 3)";
          };
        };

        assetsDir = pkgs.symlinkJoin {
          name = "v2rayb-assets";
          paths = with pkgs; [
            v2ray-geoip
            v2ray-domain-list-community
          ];
        };

        v2rayb = pkgs.buildGoModule rec {
          pname = "v2rayb";
          inherit version;
          src = ./.;
          vendorHash = "sha256-uiURsB1V4IB77YKLu5gdaqw9Fuja6fC5adWYDE3OE+Q=";

          modRoot = "./service";
          doCheck = false;

          ldflags = [
            "-s" "-w"
            "-X github.com/v2rayA/v2rayA/conf.Version=${version}"
          ];

          subPackages = [ "." ];

          nativeBuildInputs = [ pkgs.makeWrapper ];

          preBuild = ''
            cp -a ${gui}/* server/router/web/
          '';

          postInstall = ''
            mv $out/bin/v2rayA $out/bin/v2rayb

            wrapProgram $out/bin/v2rayb \
              --prefix PATH ":" "${pkgs.lib.makeBinPath [ pkgs.v2ray ]}" \
              --prefix XDG_DATA_DIRS ":" "${assetsDir}/share"
          '';

          passthru = {
            inherit gui;
            override = args: v2rayb.overrideAttrs (old: {
              postInstall = ''
                mv $out/bin/v2rayA $out/bin/v2rayb

                wrapProgram $out/bin/v2rayb \
                  --prefix PATH ":" "${pkgs.lib.makeBinPath [ (args.v2ray or pkgs.v2ray) ]}" \
                  --prefix XDG_DATA_DIRS ":" "${assetsDir}/share"
              '';
            });
          };

          meta = {
            description = "v2rayB - web GUI client for V2Ray, Xray, SS, SSR, Trojan";
            homepage = "https://github.com/keepinfov/v2rayB";
            license = pkgs.lib.licenses.agpl3Only;
            platforms = pkgs.lib.platforms.linux;
            mainProgram = "v2rayb";
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

          meta = {
            description = "v2rayB Desktop wrapper (Tauri)";
            homepage = "https://github.com/keepinfov/v2rayB";
            license = pkgs.lib.licenses.agpl3Only;
            mainProgram = "v2rayb-desktop";
          };
        };

      in {
        packages = {
          default = v2rayb;
          inherit v2rayb v2rayb-desktop gui;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            nodejs
            yarn
            cargo
            rustc
            pkg-config
            v2ray
          ] ++ desktopLibs;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath desktopLibs;
        };
      }
    ) // {
      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.v2rayb;
          nftablesEnabled = config.networking.nftables.enable;
          iptablesServices = [ "iptables.service" ]
            ++ lib.optional config.networking.enableIPv6 "ip6tables.service";
          tableServices = if nftablesEnabled then [ "nftables.service" ] else iptablesServices;
        in {
          options.services.v2rayb = {
            enable = lib.mkEnableOption "v2rayB service";

            address = lib.mkOption {
              type = lib.types.str;
              default = "localhost:50541";
              description = "Listen address for the web interface";
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.system}.v2rayb;
              description = "The v2rayB package to use";
            };

            cliPackage = lib.mkOption {
              type = lib.types.package;
              default = pkgs.v2ray;
              example = "pkgs.xray";
              description = "The v2ray/xray package to use as the core";
            };

            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              example = [ "--log-level=debug" ];
              description = "Extra arguments to pass to v2rayb";
            };

            desktop = lib.mkEnableOption "v2rayB desktop client";
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ (cfg.package.override { v2ray = cfg.cliPackage; }) ]
              ++ lib.optional cfg.desktop self.packages.${pkgs.system}.v2rayb-desktop;

            systemd.services.v2rayb = {
              description = "v2rayB Service";
              documentation = [ "https://github.com/keepinfov/v2rayB" ];
              after = [ "network.target" "nss-lookup.target" ] ++ tableServices;
              wants = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                User = "root";
                ExecStart = "${lib.getExe (cfg.package.override { v2ray = cfg.cliPackage; })} --address ${cfg.address} --log-disable-timestamp ${lib.concatStringsSep " " cfg.extraArgs}";
                Environment = [ "V2RAYA_LOG_FILE=/var/log/v2rayb/v2rayb.log" ];
                LimitNPROC = 500;
                LimitNOFILE = 1000000;
                Restart = "on-failure";
                Type = "simple";
              };

              path = with pkgs; [
                iptables
                bash
                iproute2
              ] ++ lib.optionals nftablesEnabled [ nftables ];
            };
          };
        };
    };
}
