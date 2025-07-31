{
  description = "ha8ta6's Gitlint configuration.";

  outputs =
    inputs@{
      flake-parts,
      pre-commit,
      systems,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShellNoCC {
            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          pre-commit.settings.hooks = {
            nixfmt-tree = {
              enable = true;
              name = "nixfmt-tree";
              description = "Format the Nix files.";
              entry = "${pkgs.nixfmt-tree}/bin/treefmt";
              files = "\\.nix$";
            };

            statix = {
              enable = true;
              description = "Detects anti-patterns in Nix files.";
              after = [ "nixfmt-tree" ];
            };

            deadnix = {
              enable = true;
              description = "Detects unused variables in Nix files.";
              after = [ "nixfmt-tree" ];
            };

            taplo = {
              enable = true;
              description = "Format the TOML files.";
            };

            check-toml = {
              enable = true;
              description = "Detects anti-patterns in TOML files.";
              after = [ "taplo" ];
            };

            prettier = {
              enable = true;
              description = "Format the YAML and Markdown files.";
              files = "\\.(yml|yaml|md)$";
            };

            markdownlint = {
              enable = true;
              description = "Detects anti-patterns in Markdown files.";
              entry = "${pkgs.markdownlint-cli}/bin/markdownlint --disable MD033 MD041 --";
              after = [ "prettier" ];
            };

            yamllint = {
              enable = true;
              description = "Detects anti-patterns in YAML files.";
              entry = "${pkgs.yamllint}/bin/yamllint -sd \"{rules: {line-length: {max: 120}, document-start: disable}}\"";
              after = [ "prettier" ];
            };
          };
        };

      imports = [
        pre-commit.flakeModule
      ];

      # Used nix-systems to improve maintainability and readability.
      # If you want to change the supported systems, change `inputs.systems.url`.
      systems = import systems;
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    pre-commit = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    systems = {
      url = "github:nix-systems/x86_64-linux";
      flake = false;
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
}
