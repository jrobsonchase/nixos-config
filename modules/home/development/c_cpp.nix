{ self, ... }:
{
  flake.homeModules.c_cpp =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.vscode = {
        profiles.default.extensions = with pkgs.vscode-extensions; [
          # ms-vscode.cpptools
        ];
      };

      home.packages = with pkgs; [
        # gcc
        # binutils
        # clang
        # lldb
      ];
    };
}
