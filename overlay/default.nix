{ inputs, lib, ... }:
final: prev:
let
  inherit (lib) liftAttr;

  inputPackages = liftAttr final.system (liftAttr "packages" inputs);

  nixpkgs = import inputs.nixpkgs {
    system = final.system;
    config.allowUnfree = true;
  };

  inherit (inputPackages) home-manager cargo2nix tokio-console;
in
{
  # Make sure steam *always* comes from nixpkgs-unstable.
  # This is because the easiest way to get steam working is by including it in
  # the system config, and it'll use the slower-updating `nixos-unstable` flake.
  steam = nixpkgs.steam;

  # Make it easier to include home-manager at the system level to bootstrap user
  # configuration.
  home-manager = home-manager.home-manager;

  # The rest of these are really only used in home-manager configs, not system
  # configs. It might be a bit more "correct" to have separate overlays, but I'm
  # lazy :P

  cargo2nix = cargo2nix.cargo2nix;

  tokio-console = tokio-console.tokio-console;

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
  hmFlake = final.writeShellScriptBin "flake-manager" ''
    set -x
    home-manager "$@" --flake "''$HOME/.config/nixpkgs"
  '';

  # nixpkgs-fmt wrapper to format all nix files under the current directory
  nixfmt = final.writeShellScriptBin "nixfmt" ''
    PATH=${final.findutils}/bin:${prev.nixpkgs-fmt}/bin
    find . -name '*.nix' | xargs nixpkgs-fmt "$@"
  '';
}
