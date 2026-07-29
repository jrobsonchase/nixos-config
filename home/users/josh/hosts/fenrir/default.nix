{
  flakeModules,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../sway-full.nix
    flakeModules.gitsign
    flakeModules.opencode
    flakeModules.claude
    flakeModules.pi
  ];

  home.packages = with pkgs; [
    gh
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    obsidian
    (symlinkJoin {
      name = "claude-desktop-with-chrome";
      paths = [ claude-desktop ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        for bin in "$out"/bin/*; do
          wrapProgram "$bin" --prefix PATH : ${lib.makeBinPath [ google-chrome ]}
        done
      '';
    })
  ];
}
