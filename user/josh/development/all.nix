{ config, lib, pkgs, ... }:
{
  imports = [
    ./.
    ./rust.nix
    ./rune.nix
    ./go.nix
    ./dotnet.nix
    ./c_cpp.nix
    ./sql.nix
    ./lua.nix
    ./kubernetes.nix
    ./deno.nix
    ./bazel.nix

    ./vscode.nix
  ];
}
