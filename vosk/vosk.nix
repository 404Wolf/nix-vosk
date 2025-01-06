{
  stdenv,
  fetchFromGitHub,
  callPackage,
}: let
  kaldi = callPackage ./kaldi.nix {};
  openblas = callPackage ./openblas.nix {};
  openfst = callPackage ./openfst.nix {};
in
  stdenv.mkDerivation {
    name = "libvosk";
    version = "0.0.0";

    src = fetchFromGitHub {
      owner = "alphacep";
      repo = "vosk-api";
      rev = "cf67ed6cd9c022a5550670c16ff8a0e345cf77db";
      sha256 = "sha256-PTS5ohvDb/l5PBIa7XtYpaRLQ4Ik6wc2WY8EGdTZkIw=";
    };

    nativeBuildInputs = [
      kaldi
      openfst
      openblas
    ];

    buildPhase = ''
      rm src/Makefile
      cp ${./Makefile} src/Makefile

      # export KALDI_ROOT=${kaldi};
      # export OPENFST_ROOT=${openfst};
      # export OPENBLAS_ROOT=${openblas};

      export USE_SHARED=1;
      export EXTRA_CFLAGS="$(find ${kaldi}/include/kaldi -type d | xargs -I {} echo "-I{}")";
      echo $EXTRA_CFLAGS

      cd src
      make
    '';

    installPhase = ''
      mkdir -p $out
      cp -r * $out
    '';
  }
