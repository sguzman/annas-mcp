{
  description = "Flake for sguzman/annas-mcp (Go project)";

  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url    = "github:numtide/flake-utils";
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      goEnv     = gomod2nix.legacyPackages.${system}.mkGoEnv;
      gomod2nixT = gomod2nix.legacyPackages.${system}.gomod2nix;
    in {
      packages.${system}.annas-mcp = pkgs.buildGoApplication {
        pname   = "annas-mcp";
        version = "0.1.0";
        src     = ./.;
        modules = ./gomod2nix.toml;
      };

      defaultPackage = self.packages.${system}.annas-mcp;

      devShell = pkgs.mkShell {
        buildInputs = [
          goEnv
          gomod2nixT
          pkgs.go_1_21
        ];

        shellHook = ''
          export GOMODCACHE="$PWD/.gomodcache"
          if [ ! -f gomod2nix.toml ]; then
            echo "🌟 Generating gomod2nix.toml…"
            gomod2nix generate
          fi
        '';
      };
    });
}

