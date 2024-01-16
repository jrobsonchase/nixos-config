{ ... }:
with builtins;
let
  makeJob = rev: description: {
    inherit description;
    flake = "gitlab:jrobsonchase/nixos-config/${rev}";
    type = 1;
    enabled = 1;
    hidden = false;
    keepnr = 0;
    schedulingshares = 1;
    checkinterval = 300;
    enableemail = false;
    emailoverride = "";
  };
  makeSpec = contents: derivation {
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
in
{
  jobsets = makeSpec {
    flake-update = makeJob "flake-update" "flake-update branch";
    main = makeJob "main" "main branch";
  };
}
