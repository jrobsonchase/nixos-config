{ flakeModules, ... }:
{
  imports = [
    flakeModules.josh-sway-full
    flakeModules.opencode
  ];

  programs.gpg.scdaemonSettings.disable-ccid = false;
}
