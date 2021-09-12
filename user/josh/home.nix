{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktop.nix
  ];
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = true;
  };

  programs.git = {
    enable = true;
    userName = "Josh Robson Chase";
    userEmail = "josh@robsonchase.com";
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset %C(green)%G?%Creset%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
    extraConfig = {
      rerere.enabled = true;
      tag.forceSignAnnotated = true;
    };
    signing = {
      signByDefault = true;
      key = null;
    };
  };

  programs.firefox = {
    enable = true;
    profiles.default.settings = {
      "browser.ctrlTab.sortByRecentlyUsed" = true;
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [
    vim_configurable
    fira-code
    font-awesome
    aegyptus

    wireshark
    nmap-graphical
    scrot
    stow
    dunst
    gnupg
    ripgrep
    picom
    ibus
    polybarFull
    libnotify
    tree
    file
    glxinfo
    slack
    discord
    autorandr
    vscode
    usbutils
    htop

    rust-analyzer
    cargo
    rustc
    rustfmt

    rxvt-unicode
    awscli

    pavucontrol

    arandr

    xclip

    clang

    keepassxc

    spotify
    # steam-run
    # steam
  ];
}
