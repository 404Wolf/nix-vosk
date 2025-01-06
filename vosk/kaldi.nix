{
  callPackage,
  fetchFromGitHub,
  kaldi,
  icu,
}: let
  openfst = callPackage ./openfst.nix {};
  openblas = callPackage ./openblas.nix {};
in
  kaldi.overrideAttrs (prevAttrs: {
    buildInputs = [
      openblas
      openfst
      icu
    ];

    src = fetchFromGitHub {
      owner = "alphacep";
      repo = "kaldi";
      rev = "bc5baf14231660bd50b7d05788865b4ac6c34481";
      sha256 = "sha256-nFIKzBRZ6Og0Oj1wuYRMN33e1uZli5OLZSdnjUIybfg=";
    };

    passthru.sources.openfst = openfst.src;
  })
