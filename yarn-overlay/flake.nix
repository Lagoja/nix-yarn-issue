{
  description =
    "This flake outputs a modified version of Yarn that uses NodeJS 16.x";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      # You can define overlays as functions using the example below
      # This overlay will modify yarn to use nodejs-16_x
      yarnOverlay = (final: prev: {
        yarn = prev.yarn.override { nodejs = final.pkgs.nodejs-16_x; };
      });

      # This function applies our overlay to nixpkgs for all supported systems
      pkgs =
        import nixpkgs {
          inherit system;
          # Add your overlays to the list below. Note that they will be applied in order
          overlays = [ yarnOverlay ];
        };

    in {
      # For our outputs, we'll return the modified Yarn package from our overridden nixpkgs.
      packages.yarn = pkgs.yarn;

      # Set yarn as the default package output for this flake
      defaultPackage = self.packages.yarn;
    }
  );
}

