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
      pkgs = import nixpkgs {inherit system;};

      python = pkgs.python3.withPackages (ps:
        with ps; [
          tqdm
        ]);
    in {
      packages = rec {
        default = vosk;
        vosk = pkgs.callPackage ./package.nix {};
        models = pkgs.callPackage ./models {};
      };
      devShells.default = pkgs.mkShell {
        packages = [
          python
        ];
      };
    });
}
