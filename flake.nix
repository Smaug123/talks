{
  description = "Environment for building talks";
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in let
        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-medium mdframed etoolbox zref needspace tikz-cd;
        };
      in let
        vscodeExtensions = [
          pkgs.vscode-extensions.vscodevim.vim
          pkgs.vscode-extensions.james-yu.latex-workshop
        ];
      in let
        vscode =
          pkgs.vscode-with-extensions.override {
            vscodeExtensions = vscodeExtensions;
          };
      in {
        packages = flake-utils.lib.flattenTree {
          gitAndTools = pkgs.gitAndTools;
        };
        devShell =
          pkgs.mkShell {buildInputs = [texlive vscode];};

        defaultPackage = let
          createShellScript = name: contents:
            pkgs.stdenv.mkDerivation {
              pname = name;
              version = "0.1.0";
              src = contents;

              buildInputs = [
                pkgs.shellcheck
              ];

              phases = ["configurePhase" "buildPhase" "installPhase"];

              configurePhase = ''
                ${pkgs.shellcheck}/bin/shellcheck "${contents}"
              '';

              buildPhase = ''
                cp "${contents}" run.sh
                patchShebangs run.sh
                sed -i 's_"/bin/sh"_"${pkgs.bash}/bin/sh"_' run.sh
              '';

              installPhase = ''
                mkdir -p $out
                mv run.sh $out/run.sh
              '';
            };
        in let
          buildLatex =
            createShellScript "latex" ./build.sh;
        in
          pkgs.stdenv.mkDerivation {
            pname = "patrick-talks";
            version = "0.1.0";
            src = ./.;
            buildInputs = [
              texlive
            ];

            buildPhase = ''
              ${pkgs.bash}/bin/sh ${buildLatex}/run.sh .
            '';

            installPhase = ''
              mkdir -p $out
              mv ./* $out
            '';
          };
      }
    );
}
