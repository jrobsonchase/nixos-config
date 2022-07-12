{ lib, system, symlinkJoin, nodePackages, gnused, vscode-utils, runCommand, rustPlatform, callPackage, fetchFromGitHub }:
let
  version = "0.10.3";
  repo = fetchFromGitHub {
    rev = version;
    owner = "rune-rs";
    repo = "rune";
    sha256 = "sha256-4w48ZKAaS9eNE6hO+LXDw619LKbpWSZBYQ51F5kSSYQ=";
  };
  node2nix = src: runCommand "node2nix"
    {
      inherit src;
      nativeBuildInputs = [
        nodePackages.node2nix
      ];
    } ''
    cp -r $src $out
    chmod -R +w $out
    cd $out
    node2nix --development -l package-lock.json
  '';
  extNix = node2nix (repo + "/editors/code");
  extBuild = (callPackage extNix { }).package.override {
    propagatedBuildInputs = [
      rune
    ];
    postInstall = ''
      substitute ${./rune-vscode/rune-vscode.patch} ./rune-vscode.patch \
        --subst-var-by lsPath ${rune}/bin/rune-languageserver

      patch -p3 < rune-vscode.patch

      npm run build
      npm install --production
    '';
  };
  vscode-extension = vscode-utils.buildVscodeExtension {
    name = "rune-vscode";
    src = extBuild + "/lib/node_modules/rune-vscode";
    vscodeExtUniqueId = "udoprog.rune-vscode";
  };
  rune = rustPlatform.buildRustPackage rec {
    name = "rune";
    inherit version;
    src = symlinkJoin {
      name = "rune-src";
      paths = [
        repo
        ./rune-rs
      ];
    };
    cargoLock = {
      lockFile = src + "/Cargo.lock";
    };
  };
in
{
  inherit vscode-extension rune;
}
