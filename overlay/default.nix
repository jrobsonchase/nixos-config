{ inputs, lib, ... }:
final: prev:
let
  inherit (lib) liftAttr;

  inputPackages = liftAttr final.system (liftAttr "packages" inputs);

  nixpkgs = import inputs.nixpkgs {
    system = final.system;
    config.allowUnfree = true;
  };

  inherit (inputPackages) home-manager mudrs-milk nix;
in
{
  # Make it easier to include home-manager at the system level to bootstrap user
  # configuration.
  home-manager = home-manager.home-manager;

  # The rest of these are really only used in home-manager configs, not system
  # configs. It might be a bit more "correct" to have separate overlays, but I'm
  # lazy :P

  mudrs-milk = mudrs-milk.mudrs-milk;

  cryptowatch-desktop = final.callPackage ./cryptowatch.nix { };

  pixelorama = final.callPackage ./pixelorama.nix { };

  # Convenience wrapper for nixos-rebuild to point to where I keep my
  # configuration.
  nixosFlake = final.writeShellScriptBin "flake-rebuild" ''
    set -x
    sudo nixos-rebuild "$@" --flake "''$HOME/.config/nixpkgs"
  '';

  # Convenience wrapper for home-manager to point to where I keep my
  # configuration.
  homeFlake = final.writeShellScriptBin "flake-manager" ''
    set -x
    home-manager "$@" --flake "''$HOME/.config/nixpkgs"
  '';

  # Convenience wrapper for nix-on-droid to point to where I keep my
  # configuration.
  nodFlake = final.writeShellScriptBin "flake-on-droid" ''
    set -x
    nix-on-droid "$@" --flake "''$HOME/.config/nixpkgs#device"
  '';

  nixosDiff = final.writeShellScriptBin "nixos-diff" ''
    set -e
    TMPDIR=$(mktemp -d)
    function cleanup() {
      rm -r $TMPDIR
    }
    trap cleanup EXIT

    cd $TMPDIR
    flake-rebuild build
    nix store diff-closures /run/current-system ./result
  '';

  homeDiff = final.writeShellScriptBin "home-diff" ''
    set -e
    TMPDIR=$(mktemp -d)
    function cleanup() {
      rm -r $TMPDIR
    }
    trap cleanup EXIT

    cd $TMPDIR
    flake-manager build
    nix store diff-closures /nix/var/nix/profiles/per-user/$USER/home-manager ./result
  '';

  # nixpkgs-fmt wrapper to format all nix files under the current directory
  nixfmt = final.writeShellScriptBin "nixfmt" ''
    PATH=${final.findutils}/bin:${prev.nixpkgs-fmt}/bin
    find . -name '*.nix' | xargs nixpkgs-fmt "$@"
  '';

  runePackages = final.callPackage ./rune { };
}
