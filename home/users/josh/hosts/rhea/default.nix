{ flakeModules, ... }:
{
  imports = [
    ../../sway-full.nix
    flakeModules.opencode
  ];

  programs.gpg.scdaemonSettings.disable-ccid = false;
}
