{ self, ... }:
{
  flake.homeModules.josh-i3-full =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.josh
        self.homeModules.desktop
        self.homeModules.development-all
      ];

      xsession.windowManager.i3.enable = true;

      home.packages = with pkgs; [
        deskflow
      ];
    };
}
