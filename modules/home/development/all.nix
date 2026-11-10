{ self, ... }:
{
  flake.homeModules.development-all =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.development
        self.homeModules.rust
        self.homeModules.rune
        self.homeModules.go
        self.homeModules.c_cpp
        self.homeModules.sql
        self.homeModules.lua
        self.homeModules.kubernetes
        # self.homeModules.deno
        # self.homeModules.bazel

        # self.homeModules.vscode
        self.homeModules.zed
      ];
    };
}
