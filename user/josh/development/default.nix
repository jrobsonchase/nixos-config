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
    # ./clojure.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    awscli2

    vim_configurable
  ];
}
