{
  description = "Kyle Manna's Blog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Shared function to build the Jekyll site
      mkSite = pkgs: pkgs.stdenv.mkDerivation {
        pname = "blog-kylemanna-com";
        version = "1.0.0";

        src = ./.;

        nativeBuildInputs = [
          pkgs.git
          pkgs.rubyPackages.jekyll-paginate
        ];

        buildPhase = ''
          export HOME=$TMPDIR
          export JEKYLL_ENV=production
          export JEKYLL_NO_BUNDLER_REQUIRE=1

          rm -rf _site

          # Build the site with jekyll
          ${pkgs.jekyll}/bin/jekyll build
        '';

        installPhase = ''
          mkdir -p $out/www
          cp -r _site/* $out/www/
        '';
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Build the Jekyll site
        site = mkSite pkgs;

        # Minimal Caddy server for development
        devServer = pkgs.writeShellScriptBin "blog-dev-server" ''
          set -e
          export PORT=8080
          echo "Starting development server on http://localhost:$PORT"
          echo "Serving from: ${site}/www"
          echo ""
          cd "${site}/www"
          exec ${pkgs.caddy}/bin/caddy run --config ${./Caddyfile} --adapter caddyfile
        '';
      in
      {
        packages = {
          default = site;
          site = site;
          devServer = devServer;
        };

        apps = {
          default = {
            type = "app";
            program = "${devServer}/bin/blog-dev-server";
          };
          dev = {
            type = "app";
            program = "${devServer}/bin/blog-dev-server";
          };
        };
      }
    ) // {
      # NixOS module output for easy integration
      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.services.blog-kylemanna;

          # Build the Jekyll site
          site = mkSite pkgs;
        in {
          options.services.blog-kylemanna = {
            enable = mkEnableOption "blog.kylemanna.com website";

            port = mkOption {
              type = types.port;
              default = 8080;
              description = "TCP port for the web server";
            };
          };

          config = mkIf cfg.enable {
            systemd.services.blog-kylemanna = {
              description = "blog.kylemanna.com web server";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "notify";
                ExecStart = "${pkgs.caddy}/bin/caddy run --config ${./Caddyfile} --adapter caddyfile";
                Environment = [
                  "PORT=${toString cfg.port}"
                  "HOME=%t/blog-kylemanna"
                  "XDG_DATA_HOME=%t/blog-kylemanna/data"
                  "XDG_CACHE_HOME=%t/blog-kylemanna/cache"
                  "XDG_STATE_HOME=%t/blog-kylemanna/state"
                ];
                WorkingDirectory = "${site}/www";

                # Private runtime
                RuntimeDirectory = "blog-kylemanna";
                RuntimeDirectoryMode = "0700";

                # Security hardening
                DynamicUser = true;
                ProtectSystem = "strict";
                ProtectHome = true;
                PrivateTmp = true;
                NoNewPrivileges = true;
                PrivateDevices = true;
                ProtectKernelTunables = true;
                ProtectKernelModules = true;
                ProtectControlGroups = true;
                RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
                RestrictNamespaces = true;
                LockPersonality = true;
                RestrictRealtime = true;
                RestrictSUIDSGID = true;
                RemoveIPC = true;
                CapabilityBoundingSet = "";
                SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
              };
            };
          };
        };
    };
}
