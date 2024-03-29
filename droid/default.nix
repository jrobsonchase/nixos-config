{ pkgs, config, ... }:

{
  imports = [
    ../host/cachix.nix
  ];

  nix = {
    extraConfig = ''
      max-jobs = 8
    '';
  };

  # Simply install just the packages
  environment.packages = with pkgs; [
    vim

    file
    coreutils
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnupg
    gnugrep
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip

    git
    openssh
  ];

  nix = {
    package = pkgs.nix;
  };

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  system.stateVersion = "21.11";

  home-manager.useGlobalPkgs = true;
  home-manager.config =
    { pkgs, ... }:
    {
      imports = [
        ../user/common.nix
      ];

      home.packages = with pkgs; [
        nodFlake
        mudrs-milk
      ];

      # Read the changelog before changing this value
      home.stateVersion = "21.11";
    };
}

# vim: ft=nix
