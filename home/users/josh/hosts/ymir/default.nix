{
  pkgs,
  lib,
  config,
  inputModules,
  flakeModulesPath,
  ...
}:
{
  imports =
    (map (p: flakeModulesPath + "/" + p) [
      "."
      "development"
      "development/zed.nix"
      "development/go.nix"
      "gpg.nix"
      "git.nix"
      "jujutsu"
      "zellij.nix"
    ])
    ++ [
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
