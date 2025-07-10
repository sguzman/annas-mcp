{
  description = "Flake for sguzman/annas-mcp (Go project)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:nix-community/gomod2nix";
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gomod2nixPkg = gomod2nix.legacyPackages.${system};
      in {
        packages.default = gomod2nixPkg.buildGoApplication {
          pname = "annas-mcp";
          version = "0.1.0";
          src = ./.;
          modules = ./gomod2nix.toml;
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.go
            gomod2nixPkg.gomod2nix
          ];

          shellHook = ''
            export GOMODCACHE=$PWD/.gomodcache
            if [ ! -f gomod2nix.toml ]; then
              echo "Generating gomod2nix.toml..."
              gomod2nix generate
            fi
          '';
        };
      }
    );
}

