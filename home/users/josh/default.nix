{
  config,
  lib,
  pkgs,
  inputModules,
  flakeModulesPath,
  ...
}:
{
  imports =
    (map (p: flakeModulesPath + "/" + p) [
      "."
      "gpg.nix"
      "git.nix"
      "jujutsu"
      "development"
    ])
    ++ [
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
