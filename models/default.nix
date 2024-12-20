{
  runCommand,
  unzip,
  ...
}: let
  models = builtins.fromJSON (builtins.readFile ./models.json);
in
  builtins.listToAttrs (builtins.map (model: {
      name = model.model_name;
      value =
        runCommand "model-${model.model_name}" {
          src = builtins.fetchurl {
            url = model.url;
            sha256 = model.hash;
          };
          nativeBuildInputs = [unzip];
        } ''
          mkdir -p $out
          unzip $src -d $out
          folder=$(ls $out)
          mv $out/$folder/* $out
          rm -rf $out/$folder
        '';
    })
    models)
