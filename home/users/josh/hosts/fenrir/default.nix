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
  ];
}
