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
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "python-2.7.18.8"
          ];
        };
      };

      python = pkgs.python3.withPackages (ps:
        with ps; [
          tqdm
        ]);
    in {
      packages = rec {
        default = vosk;
        vosk = pkgs.callPackage ./vosk/vosk.nix {};
        openfst = pkgs.callPackage ./vosk/openfst.nix {};
        openblas = pkgs.callPackage ./vosk/openblas.nix {};
        models = pkgs.callPackage ./models {};
        kaldi = pkgs.callPackage ./vosk/kaldi.nix {};
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # wget
          # bzip2
          # unzip
          # xz
          # cmake
          # git
          # python
          # zlib
          # automake
          # autoconf
          # libtool
          # pkg-config
          # sox
          # gfortran
          # python2
          # subversion
          # mkl
          # openblas
          # (pkgs.callPackage ./vosk/openblas.nix {})
          (pkgs.callPackage ./vosk/openfst.nix {})
          # (pkgs.callPackage ./vosk/kaldi.nix {})
        ];
      };
    });
}
