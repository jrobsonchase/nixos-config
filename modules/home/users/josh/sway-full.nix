{ self, ... }:
{
  flake.homeModules.josh-sway-full =
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

      wayland.windowManager.sway.enable = true;
      noctalia.enable = true;

      home.packages = with pkgs; [
        deskflow
      ];
    };
}
