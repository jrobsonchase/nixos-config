{
  lib,
  python3,
  callPackage,
  libsecret,
  makeWrapper,
  symlinkJoin,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
  supernote-cli-src,
}:

let
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = supernote-cli-src; };

  overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };

  pythonSet = (callPackage pyproject-nix.build.packages { python = python3; }).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      overlay
      (final: prev: {
        # fusepy has no Linux wheel and doesn't declare setuptools as a build dep
        fusepy = prev.fusepy.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.setuptools ];
        });
        # pycairo has no Linux wheels; uses meson-python backend + cairo C library
        pycairo = prev.pycairo.overrideAttrs (old: {
          nativeBuildInputs =
            old.nativeBuildInputs
            ++ final.resolveBuildSystem { meson-python = [ ]; }
            ++ [
              final.pkgs.pkg-config
              final.pkgs.meson
              final.pkgs.ninja
            ];
          buildInputs = (old.buildInputs or [ ]) ++ [ final.pkgs.cairo ];
        });
      })
    ]
  );

  venv = pythonSet.mkVirtualEnv "supernote-cli-env" workspace.deps.default;
in
symlinkJoin {
  name = "supernote-cli";
  paths = [ venv ];
  nativeBuildInputs = [ makeWrapper ];
  # postBuild = ''
  #   wrapProgram $out/bin/supernote \
  #     --run 'SUPERNOTE_PASSWORD=$(${libsecret}/bin/secret-tool lookup Title Supernote username "$SUPERNOTE_USER"); export SUPERNOTE_PASSWORD'
  # '';
}
