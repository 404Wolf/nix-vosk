{
  stdenv,
  fetchFromGitHub,
  callPackage,
  libf2c,
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

    KALDI_ROOT = "${kaldi}";
    OPENFST_ROOT = "${openfst}";
    OPENBLAS_INCLUDE = "${openblas.dev}/include";
    OPENBLAS_LIB = "${openblas}/lib";
    F2C_LIB = "${libf2c}/lib";
    USE_SHARED = 1;

    buildPhase = ''
      rm src/Makefile
      cp ${./Makefile} src/Makefile

      cd src

      make
    '';

    installPhase = ''
      mkdir -p $out/{include,lib,src}

      cp *.h $out/include
      cp *.cc $out/src
      cp *.so $out/lib
    '';
  }
