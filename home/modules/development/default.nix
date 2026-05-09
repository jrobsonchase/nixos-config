{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./nix.nix
    ./helix.nix
  ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };
  programs.opencode = {
    enable = true;
  };

  home.packages = with pkgs; [
    github-copilot-cli
  ];
}
