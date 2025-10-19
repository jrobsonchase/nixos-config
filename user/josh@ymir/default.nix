{ pkgs, lib, config, inputModules, ... }:
{
  imports = [
    ../common.nix
    ../josh/development
    ../josh/development/go.nix
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
    pkgs.copilot-language-server
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  # Set EDITOR to emacsclient
  programs.bash.sessionVariables = {
    EDITOR = "${pkgs.emacs}/bin/emacsclient";
    VISUAL = "${pkgs.emacs}/bin/emacsclient";
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.gpg.scdaemonSettings = {
    disable-ccid = false;
  };

  # programs.alacritty.settings.font.size = lib.mkForce 14;
}
