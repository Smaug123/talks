{
  description = "Environment for building talks";
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in

      let texlive = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-medium mdframed etoolbox zref needspace tikz-cd;
      }; in
      {
        packages = flake-utils.lib.flattenTree {
          gitAndTools = pkgs.gitAndTools;
        };
        defaultPackage = pkgs.stdenv.mkDerivation {
            pname = "patrick-talks";
            version = "0.1.0";
            src = ./;
            buildInputs = [
              texlive
            ];

            buildPhase = ''
              find . -type f -name '*.tex' | xargs pdflatex
            ''

            installPhase = ''
              mkdir -p $out
              mv . $out
            '';
        }
      }
