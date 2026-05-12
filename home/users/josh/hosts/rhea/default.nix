{ ... }:
{
  imports = [
    ../../sway-full.nix
  ];

  programs.gpg.scdaemonSettings.disable-ccid = false;
}
