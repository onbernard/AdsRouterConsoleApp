{
  description = "AdsRouterConsoleApp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {self, ...}:
    with inputs;
      flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlay = [];
        };

        AdsRouterConsoleApp = pkgs.buildDotnetModule {
          pname = "AdsRouterConsoleApp";
          version = "0.0.1";
          src = pkgs.fetchFromGitHub {
            owner = "Beckhoff";
            repo = "TF6000_ADS_DOTNET_V5_Samples";
            rev = "1622ecc";
            hash = "sha256-Y6D5QU2UEjNxgzX48UTWgy2+be+pFGXq/41/B1O2iuw=";
          };
          nugetDeps = ./deps.json;
          projectFile = "Sources/RouterSamples/AdsRouterConsoleApp/AdsRouterConsoleApp.sln";
          meta = with pkgs.lib; {
            description = "simple TCP ADS Router binary 'ready-to-run'";
            homepage = "https://github.com/Beckhoff/TF6000_ADS_DOTNET_V5_Samples/tree/main";
            license = {
              spdxId = "0BSD";
              free = true;
              deprecated = false;
            };
            maintainers = ["onbernard"];
            platforms = platforms.linux;
          };
        };
      in {
        packages = {
          AdsRouterConsoleApp = AdsRouterConsoleApp;
        };
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            (with dotnetCorePackages;
              combinePackages [
                sdk_8_0
                dotnet_8.aspnetcore
                dotnet_8.runtime
              ])
            nuget-to-nix
            nuget-to-json
            (writeShellScriptBin "fetch-deps" ''
              nix build .#AdsRouterConsoleApp.fetch-deps
              ./result ./deps.json
            '')
          ];
          shellHook = ''
            export DOTNET_CLI_TELEMETRY_OPTOUT=1
          '';
        };
      });
}
