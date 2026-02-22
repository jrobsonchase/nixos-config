{ inputs, lib, ... }:
final: prev:
let
  inherit (lib) liftAttr;

  system = final.stdenv.hostPlatform.system;

  inputPackages = liftAttr system (liftAttr "packages" inputs);

  inherit (inputPackages) home-manager;
in
{
  crossRpi5 = import inputs.nixpkgs {
    system = "x86_64-linux";
    crossSystem = {
      config = "aarch64-linux";
    };
    overlays = [ inputs.nix-rpi5.overlays.default ];
  };

  citrix = final.citrix_workspace.overrideAttrs (attrs: {
    version = "23.7.0.17";
    src = final.stdenv.mkDerivation {
      name = "linuxx64-23.7.0.17.tar.gz";
      outputHash = "sha256-1AASJuebU1P8dNpMjtT2KVwYWf4YFCy13jRaPHrkgWg=";
      outputHashAlgo = "sha256";
      outputHashMode = "flat";
      allowSubstitutes = true;
    };
  });

  # Make it easier to include home-manager at the system level to bootstrap user
  # configuration.
  home-manager = home-manager.home-manager;

  discord = prev.discord.override {
    nss = prev.nss_latest;
  };

  determinate-nix = inputs.determinate.inputs.nix.packages.${system}.default;

  nixos-rebuild = prev.nixos-rebuild.override {
    nix = final.determinate-nix;
  };

  # Convenience wrapper for nixos-rebuild to point to where I keep my
  # configuration.
  nixos-flake = final.writeShellScriptBin "flake-rebuild" ''
    set -x
    sudo ${final.nixos-rebuild}/bin/nixos-rebuild "$@" --flake "''$HOME/.config/nixpkgs"
  '';

  # Convenience wrapper for home-manager to point to where I keep my
  # configuration.
  home-flake = final.writeShellScriptBin "flake-manager" ''
    set -x
    ${final.home-manager}/bin/home-manager "$@" --flake "''$HOME/.config/nixpkgs"
  '';

  # Convenience wrapper for nix-on-droid to point to where I keep my
  # configuration.
  nod-flake = final.writeShellScriptBin "flake-on-droid" ''
    set -x
    ${final.nix-on-droid}/bin/nix-on-droid "$@" --flake "''$HOME/.config/nixpkgs#device"
  '';

  nixos-diff = final.writeShellScriptBin "nixos-diff" ''
    set -e
    TMPDIR=$(mktemp -d)
    function cleanup() {
      rm -r $TMPDIR
    }
    trap cleanup EXIT

    cd $TMPDIR
    ${final.nixos-flake}/bin/flake-rebuild build
    nix store diff-closures /run/current-system ./result
  '';

  home-diff = final.writeShellScriptBin "home-diff" ''
    set -e
    TMPDIR=$(mktemp -d)
    function cleanup() {
      rm -r $TMPDIR
    }
    trap cleanup EXIT

    cd $TMPDIR
    ${final.home-flake}/bin/flake-manager build
    nix store diff-closures $HOME/.local/state/home-manager/gcroots/current-home ./result
  '';

  runePackages = final.callPackage ./rune { };

  zed-editor = inputs.zed.packages.${system}.default;

  probe-rs-rules = final.callPackage ./probe-rs-rules.nix { };
}
