{
  fetchFromGitHub,
  openfst,
}:
openfst.overrideAttrs (
  oldAttrs: {
    # version = "1.8.0";

    src = fetchFromGitHub {
      owner = "alphacep";
      repo = "openfst";
      rev = "18e94e63870ebcf79ebb42b7035cd3cb626ec090";
      sha256 = "sha256-059BDNHbnim/rIMAaJ/+mD698R6chCdddOYVEtaYgfc=";
    };
  }
)
