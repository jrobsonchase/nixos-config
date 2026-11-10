{ self, ... }:
{
  flake.homeModules.development =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.nix
        self.homeModules.helix
      ];

      home.packages = with pkgs; [
        supernote-cli
      ];
    };
}
