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

        webUI = pkgs.buildNpmPackage {
          pname = "v2rayb-web";
          inherit version;
          src = ./gui;
          npmDepsHash = "sha256-0000000000000000000000000000000000000000000=";
          buildPhase = ''
            npm run build
          '';
          installPhase = ''
            cp -r dist $out
          '';
        };

        v2rayb = pkgs.buildGoModule {
          pname = "v2rayb";
          inherit version;
          src = ./service;
          vendorHash = null;

          preBuild = ''
            mkdir -p server/router/web
            cp -r ${webUI}/* server/router/web/
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

      in {
        packages = {
          default = v2rayb;
          inherit v2rayb;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ go nodejs yarn ];
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
              default = "0.0.0.0:20170";
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
