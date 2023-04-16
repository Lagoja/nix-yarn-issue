{
  description =
    "This flake outputs a modified version of Yarn that uses NodeJS 16.x";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Helper function that let's us create a nixpkg for all of our supported systems
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # You can define overlays as functions using the example below
      # This overlay will modify yarn to use nodejs-16_x
      yarnOverlay = (final: prev: {
        yarn = prev.yarn.override { nodejs = final.pkgs.nodejs-16_x; };
      });

      # This function applies our overlay to nixpkgs for all supported systems
      nixPkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          # Add your overlays to the list below. Note that they will be applied in order
          overlays = [ yarnOverlay ];
        });

    in {
      # For our outputs, we'll return the modified Yarn package from our overridden nixpkgs.
      packages = forAllSystems (system: 
      let pkgs = nixPkgsFor.${system}; 
      in { yarn = pkgs.yarn; });

      # Set yarn as the default package output for this flake
      defaultPackage = forAllSystems (system: self.packages.${system}.yarn);
    };
}

