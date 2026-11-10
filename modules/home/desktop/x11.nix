{ self, ... }:
{
  flake.homeModules.x11 =
    { pkgs, ... }:
    {
      config = {
        home.packages = with pkgs; [
          autorandr
          arandr
          xbacklight
          xev
          xmodmap
          xclip
        ];
      };
    };
}
