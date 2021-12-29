{ pkgs, config, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    vim

    # Some common stuff that people expect to have
    file
    bashInteractive
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

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  system.stateVersion = "21.11";

  home-manager.config =
    { pkgs, ... }:
    {
      # Read the changelog before changing this value
      home.stateVersion = "21.11";

      programs.bash.enable = true;
      programs.powerline-go.enable = true;
    };
}

# vim: ft=nix
