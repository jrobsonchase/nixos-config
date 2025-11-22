{
  pkgs,
  lib,
  config,
  inputModules,
  ...
}:
{
  imports = [
    ../common.nix
    ../josh/development
    ../josh/gpg.nix
    ../josh/git.nix
    ../josh/jujutsu
    ../josh/zellij.nix
    ../josh/doom

    inputModules.private.default
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = [
    pkgs.devenv
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  programs.gpg.scdaemonSettings = {
    disable-ccid = false;
  };

  # programs.alacritty.settings.font.size = lib.mkForce 14;
}
