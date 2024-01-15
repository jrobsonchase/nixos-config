{ declInput, ... }:
with builtins;
let
  defaults = {
    type = 1;
    enabled = 1;
    hidden = false;
    keepnr = 0;
    schedulingshares = 1;
    checkinterval = 300;
    flake = "gitlab:jrobsonchase/nixos-config";
    enableemail = false;
    emailoverride = "";
    inputs = {
      test = {
        type = "string";
        emailresponsible = false;
        value = toJSON declInput;
      };
    };
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
    main = defaults // {
      description = "main branch";
    };
  };
}
