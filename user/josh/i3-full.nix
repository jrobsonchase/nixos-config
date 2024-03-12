{ config, lib, pkgs, inputModules, ... }:
{
  imports = [
    ./.
    ./desktop
    ./development/all.nix

    inputModules.ngrok.ngrok
  ];

  xsession.windowManager.i3.enable = true;

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

    # (symlinkJoin {
    #   name = "sweethome3d";
    #   paths = [ sweethome3d.application ];
    #   buildInputs = [ makeWrapper ];
    #   postBuild = ''
    #     wrapProgram $out/bin/sweethome3d \
    #       --prefix JAVA_TOOL_OPTIONS ' ' '-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true'
    #   '';
    # })
    slack
    discord
    spotify
    evince

    appimage-run

    zoom-us
  ];
}
