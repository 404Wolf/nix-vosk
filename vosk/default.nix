{
  pkgs,
  symlinkJoin,
  fetchFromGitHub,
  stdenv,
  ...
}: let
  openfst = pkgs.openfst.overrideAttrs (oldAttrs: {
    src = fetchFromGitHub {
      repo = "openfst";
      owner = "alphacep";
      rev = "18e94e63870ebcf79ebb42b7035cd3cb626ec090";
      sha256 = "sha256-059BDNHbnim/rIMAaJ/+mD698R6chCdddOYVEtaYgfc=";
    };

    buildPhase = ''
      autoreconf -i

      CFLAGS="-g -O3" ./configure \
        --prefix=$out \
        --enable-static \
        --enable-shared \
        --enable-far \
        --enable-ngram-fsts \
        --enable-lookahead-fsts \
        --with-pic \
        --disable-bin

      make -j 10 && make install
    '';
  });

  openblas-build = let
    liblapack = pkgs.liblapack.override {
      shared = false;
    };
  in
    (pkgs.openblas.overrideAttrs
      (oldAttrs: {
        makeFlags =
          oldAttrs.makeFlags
          ++ [
            "ONLY_CBLAS=1"
            "DYNAMIC_ARCH=1"
          ];

        postInstall = ''
          cp ${pkgs.libf2c}/lib/libf2c.a $out/lib
          cp ${liblapack}/lib/liblapack.a $out/lib
          ln $out/lib/libopenblas.a $out/lib/libblas.a
        '';
      }))
    .override {
      enableStatic = true;
      enableShared = false;
    };

  kaldi-merge = let
    kaldi-src = fetchFromGitHub {
      repo = "kaldi";
      owner = "alphacep";
      rev = "bc5baf14231660bd50b7d05788865b4ac6c34481";
      sha256 = "sha256-nFIKzBRZ6Og0Oj1wuYRMN33e1uZli5OLZSdnjUIybfg=";
    };
    kaldi-build = pkgs.kaldi.overrideAttrs (oldAttrs: finalAttrs: {
      cmakeFlags = [
        "-DKALDI_BUILD_TEST=off"
        "-DBUILD_SHARED_LIBS=off"
        "-DBLAS_LIBRARIES=-lblas"
        "-DLAPACK_LIBRARIES=-llapack"
        "-DFETCHCONTENT_SOURCE_DIR_OPENFST:PATH=${finalAttrs.passthru.sources.openfst}"
      ];
    });
  in
    symlinkJoin {
      name = "kaldi";
      paths = [kaldi-src kaldi-build];
      postBuild = ''
        ln $out/lib/libkaldi-online2.a $out/src/online2/kaldi-online2.a
        ln $out/lib/libkaldi-decoder.a $out/src/decoder/kaldi-decoder.a
        ln $out/lib/libkaldi-ivector.a $out/src/ivector/kaldi-ivector.a
        ln $out/lib/libkaldi-gmm.a $out/src/gmm/kaldi-gmm.a
        ln $out/lib/libkaldi-tree.a $out/src/tree/kaldi-tree.a
        ln $out/lib/libkaldi-feat.a $out/src/feat/kaldi-feat.a
        ln $out/lib/libkaldi-lat.a $out/src/lat/kaldi-lat.a
        ln $out/lib/libkaldi-lm.a $out/src/lm/kaldi-lm.a
        ln $out/lib/libkaldi-rnnlm.a $out/src/rnnlm/kaldi-rnnlm.a
        ln $out/lib/libkaldi-hmm.a $out/src/hmm/kaldi-hmm.a
        ln $out/lib/libkaldi-nnet3.a $out/src/nnet3/kaldi-nnet3.a
        ln $out/lib/libkaldi-transform.a $out/src/transform/kaldi-transform.a
        ln $out/lib/libkaldi-cudamatrix.a $out/src/cudamatrix/kaldi-cudamatrix.a
        ln $out/lib/libkaldi-matrix.a $out/src/matrix/kaldi-matrix.a
        ln $out/lib/libkaldi-fstext.a $out/src/fstext/kaldi-fstext.a
        ln $out/lib/libkaldi-util.a $out/src/util/kaldi-util.a
        ln $out/lib/libkaldi-base.a $out/src/base/kaldi-base.a

        cp ${openblas-build}/lib/libopenblas.a $out/lib
      '';
    };

  clapack-src = fetchFromGitHub {
    repo = "clapack";
    owner = "alphacep";
    rev = "c13f1973ac5282c28dad9330e46d940ec2eee291";
    sha256 = "sha256-zifAvCb3IsS5n0VjfGV1iyzQ7RT0dzkz24toVl6NxJM=";
  };
in
  stdenv.mkDerivation {
    name = "vosk";

    src = fetchFromGitHub {
      name = "vosk";
      owner = "alphacep";
      repo = "vosk-api";
      rev = "a7bf6a51e299152a8fb496b928a21eb79a1d7bea";
      sha256 = "sha256-E0Xl+TbI06ArHSk1t6DsXLUlfMQZGKQMTp7smGxgp2Y=";
    };

    buildInputs = with pkgs; [
      openblas
      kaldi-merge
      kaldi-merge
      clapack-src
      openblas-build
    ];

    buildPhase = ''
      export KALDI_ROOT=${kaldi-merge}
      export OPENFST_ROOT=${openfst}
      export CLAPACK_ROOT=${clapack-src}
      export OPENBLAS_ROOT=${openblas-build}
      export USE_SHARED=1

      cd src
      make
    '';

    installPhase = ''
      mkdir -p $out/{lib,obj,include,src}

      mv *.so $out/lib
      chmod -x $out/lib/*.so

      mv *.o $out/obj
      mv *.h $out/include
      mv * $out/src
    '';
  }
