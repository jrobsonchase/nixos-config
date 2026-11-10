{
  config,
  lib,
  pkgs,
  self,
  inputModules,
  flakeModulesPath,
  ...
}:
{
  imports = [
    self.homeModules.default
    self.homeModules.gpg
    self.homeModules.git
    self.homeModules.jujutsu
    self.homeModules.development
    inputModules.private.default
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages =
    with pkgs;
    [
      jq
      tree
      bc
      file
      htop
      zip
      unzip
      dnsutils
      wget
      mtr
      mosh
      ripgrep
      openssh
      mosh
      screen
      tmux
    ]
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      xquartz
    ])
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      usbutils
      inetutils
    ]);
}
