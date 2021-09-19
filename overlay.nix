{ inputPackages, lib, ... }:
final: prev:
let
  inputSystemPackages = lib.liftAttr final.system inputPackages;

  inherit (inputSystemPackages) home-manager;
in
{
  home-manager = home-manager.home-manager;

  # Convenience wrapper for nixos-rebuild to point to where I keep my
  # configuration.
  nixosFlake = final.writeShellScriptBin "flake-rebuild" ''
    sudo nixos-rebuild "$@" --flake "''$HOME/.config/nixpkgs"
  '';

  # nixpkgs-fmt wrapper to format all nix files under the current directory
  nixfmt = final.writeShellScriptBin "nixfmt" ''
    PATH=${final.findutils}/bin:${final.nixpkgs-fmt}/bin
    find . -name '*.nix' | xargs nixpkgs-fmt "$@"
  '';
}
