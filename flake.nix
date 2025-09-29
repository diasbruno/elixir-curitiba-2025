{
  description = "package-delivery flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {

        packages.${system} = {
          default = pkgs.mkShell {
            name = "package-delivery";
            buildInputs = [pkgs.lfe pkgs.cmark];
            shellHook = ''
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath[
                                              pkgs.cmark
                                            ]};
  '';
          };
        };

        devShell = pkgs.mkShell {
          name = "package-delivery";
          buildInputs = [pkgs.lfe pkgs.cmark];
          shellHook = ''
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath[
                                            pkgs.cmark
                                          ]};
  '';
        };
      });
}
