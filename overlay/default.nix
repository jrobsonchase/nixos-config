{ inputs, lib, ... }:
final: prev:
let
  inherit (lib) liftAttr;

  inputPackages = liftAttr final.system (liftAttr "packages" inputs);

  inherit (inputPackages) home-manager mudrs-milk;
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

  # The rest of these are really only used in home-manager configs, not system
  # configs. It might be a bit more "correct" to have separate overlays, but I'm
  # lazy :P

  lapce = prev.lapce.overrideAttrs (attrs: {
    preFixup = ''
      ${attrs.preFixup}
      patchelf --add-needed ${final.libglvnd}/lib/libGL.so.1 $out/bin/lapce
      patchelf --add-needed ${final.libglvnd}/lib/libEGL.so.1 $out/bin/lapce
    '';
  });

  vscode-extensions = inputs.nix-vscode-extensions.extensions.${final.system}.vscode-marketplace // {
    rust-lang = prev.vscode-extensions.rust-lang;
    ms-vscode-remote = prev.vscode-extensions.ms-vscode-remote;
  };

  discord = prev.discord.override {
    nss = prev.nss_latest;
  };

  mudrs-milk = mudrs-milk.default;

  cryptowatch-desktop = final.callPackage ./cryptowatch.nix { };

  darling = final.callPackage ./darling.nix { };

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

  runePackages = final.callPackage ./rune { };

  # Note to self: the patches here only work for the main zed derivation, *not* the separate
  # dependencies drv that cranelib generates.
  zed-editor = inputs.zed.packages.${final.stdenv.system}.default.overrideAttrs (attrs: {
    patches = (attrs.patches or [ ]) ++ [
      # cursor offset in helix mode fix
      (final.fetchpatch {
        url = "https://github.com/zed-industries/zed/pull/46311.patch";
        hash = "sha256-vl1yD9MZA0fRBoYrRWZGbQaWaPkbKKTiLM1OU0Qq048=";
      })
      # Clear the force_cli_mode env var
      (final.fetchpatch {
        url = "https://github.com/zed-industries/zed/pull/46475.patch";
        hash = "sha256-WWn2kKURxwEVtYxJyF1GvTVBboFVuHJdcwzrezYy8aI=";
      })
    ];
  });

  probe-rs-rules = final.callPackage ./probe-rs-rules.nix { };
}
