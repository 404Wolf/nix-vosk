{
  openblas,
  fetchFromGitHub,
}:
openblas.overrideAttrs (oldAttrs: {
  name = "openblas";
  version = "v0.3.20";

  src = fetchFromGitHub {
    repo = "openblas";
    owner = "OpenMathLib";
    rev = "v0.3.20";
    sha256 = "sha256-FLPVcepf7tv/es+4kur9Op7o3iVAAayuYN4hY/P4mmQ=";
  };
})
