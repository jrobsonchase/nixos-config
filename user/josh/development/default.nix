{ config, lib, pkgs, ... }:
{
  imports = [
    ./rust.nix
    ./rune.nix
    ./go.nix
    ./dotnet.nix
    ./nix.nix
    ./vscode.nix
    ./c_cpp.nix
    ./sql.nix
    ./lua.nix
    ./kubernetes.nix
    ./deno.nix
    ./bazel.nix
    # ./clojure.nix
  ];

  home.packages = with pkgs; [
    ripgrep

    vim_configurable
  ];
}
