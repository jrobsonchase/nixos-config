{ ... }:
{
  flake.homeModules.agents =
    {
      pkgs,
      config,
      ...
    }:
    {
      home.packages = with pkgs; [
        bun
        nodejs
        supernote-cli
        uv
      ];

      home.file.".agents".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixpkgs/modules/_agents";
    };
}
