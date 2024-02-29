{ config, lib, pkgs, inputModules, ... }:
{
  imports = [
    ./desktop
    ./gpg.nix
    ./git.nix
    ./jujutsu
    ./firefox.nix
    ./development

    inputModules.private.default
    inputModules.ngrok.ngrok
  ];

  programs.ngrok = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    wireshark
    nmap

    jq
    stow
    tree
    bc
    file
    usbutils
    inetutils
    htop
    zip
    unzip
    dnsutils
    wget
    mtr
    screen

    (symlinkJoin {
      name = "sweethome3d";
      paths = [ sweethome3d.application ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/sweethome3d \
          --prefix JAVA_TOOL_OPTIONS ' ' '-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true'
      '';
    })
    geeqie
    slack
    discord
    spotify
    # mumble
    evince
    # darktable
    # libreoffice-fresh
    # mudrs-milk

    pcmanfm

    appimage-run

    # citrix
    # aseprite-unfree
    zoom-us
    # lutris

    # dwarf-fortress-packages.dwarf-fortress-full
  ];
}
