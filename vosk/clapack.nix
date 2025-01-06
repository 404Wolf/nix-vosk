{
  clapack,
  fetchFromGitHub,
}:
clapack.overrideAttrs (oldAttrs: {
  src = fetchFromGitHub {
    repo = "clapack";
    owner = "alphacep";
    rev = "c13f1973ac5282c28dad9330e46d940ec2eee291";
    sha256 = "sha256-zifAvCb3IsS5n0VjfGV1iyzQ7RT0dzkz24toVl6NxJM=";
  };
})
