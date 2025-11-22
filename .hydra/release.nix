{ ... }:
{
  dummy = builtins.derivation {
    name = "dummy.json";
    system = "x86_64-linux";
    preferLocalBuild = true;
    allowSubstitutes = false;
    builder = "/bin/sh";
    args = [
      (builtins.toFile "builder.sh" ''
        echo "$contents" > $out
      '')
    ];
    contents = builtins.toJSON {
      hello = "Jupiter!";
    };
  };
}
