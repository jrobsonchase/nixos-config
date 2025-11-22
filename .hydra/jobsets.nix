{ ... }:
with builtins;
let
  attrsToList = attrs: attrValues (mapAttrs (name: value: { inherit name value; }) attrs);
  makeSpec =
    contents:
    derivation {
      name = "spec.json";
      system = "x86_64-linux";
      preferLocalBuild = true;
      allowSubstitutes = false;
      builder = "/bin/sh";
      args = [
        (toFile "builder.sh" ''
          echo "$contents" > $out
        '')
      ];
      contents = toJSON contents;
    };
  makeJob = rev: description: {
    inherit description;
    flake = "github:jrobsonchase/nixos-config/${rev}";
    type = 1;
    enabled = 1;
    hidden = false;
    keepnr = 0;
    schedulingshares = 1;
    checkinterval = 0;
    enableemail = false;
    emailoverride = "";
  };
  pullJob =
    { name, value }:
    {
      name = value.source_branch;
      value = makeJob value.source_branch "MR ${name}: ${value.title}";
    };

  # prData = attrsToList (fromJSON (readFile pulls));
  # prJobs = listToAttrs (map pullJob prData);

  staticJobs = {
    flake-update = makeJob "flake-update" "flake-update branch";
    main = makeJob "main" "main branch";
  };

  allJobs = staticJobs; # // prJobs;
in
{
  jobsets = makeSpec allJobs;
}
