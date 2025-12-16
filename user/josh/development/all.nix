{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./.
    ./rust.nix
    ./rune.nix
    ./go.nix
    ./c_cpp.nix
    ./sql.nix
    ./lua.nix
    ./kubernetes.nix
    # ./deno.nix
    # ./bazel.nix

    # ./vscode.nix
    ./zed.nix
  ];
}
