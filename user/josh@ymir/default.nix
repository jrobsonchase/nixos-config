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

  # Set EDITOR to helix
  programs.bash.sessionVariables = {
    EDITOR = "${pkgs.helix}/bin/hx";
    VISUAL = "${pkgs.helix}/bin/hx";
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
