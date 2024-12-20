let
  models = builtins.fromJSON (builtins.readFile ./models.json);
in
  {}: builtins.listToAttrs (builtins.map (model: {
      name = model.model_name;
      value = builtins.fetchurl {
        url = model.url;
        sha256 = model.hash;
      };
    })
    models)
