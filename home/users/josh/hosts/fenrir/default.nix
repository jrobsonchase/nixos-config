{
  flakeModules,
  flakeModulesPath,
  pkgs,
  ...
}:
{
  imports = [
    ../../sway-full.nix
    flakeModules.gitsign
  ];

  home.packages = with pkgs; [
    gh
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    obsidian
  ];
}
