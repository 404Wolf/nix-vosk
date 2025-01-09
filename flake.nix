{
  description = "Nix build of the Vosk speech recognition toolkit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
      };
      python = pkgs.python3.withPackages (ps: with ps; [tqdm]);
    in rec {
      packages = rec {
        default = vosk;
        deps = {
          openfst = pkgs.callPackage ./vosk/openfst.nix {};
          openblas = pkgs.callPackage ./vosk/openblas.nix {};
          kaldi = pkgs.callPackage ./vosk/kaldi.nix {};
        };
        utils = {
          prefetch-models = pkgs.mkShellApplication {
            text = pkgs.readFile ./models/models.py;
            runtimeInputs = [python];
          };
        };
        vosk = pkgs.callPackage ./vosk/vosk.nix {};
        models = pkgs.callPackage ./models {};
      };

      apps = {
        prefetch-models = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "prefetch-models.ts" ''
            ${packages.utils.prefetch-models}
          '';
        };
      };

      devShells.default = pkgs.mkShell {
        packages =
          (with pkgs; [
            wget
            bzip2
            unzip
            xz
            cmake
            git
            zlib
            automake
            autoconf
            libtool
            pkg-config
            sox
            gfortran
            subversion
            mkl
            openblas
          ])
          ++ [
            (pkgs.callPackage ./vosk/openblas.nix {})
            (pkgs.callPackage ./vosk/openfst.nix {})
            (pkgs.callPackage ./vosk/kaldi.nix {})
            python
          ];
      };
    });
}
