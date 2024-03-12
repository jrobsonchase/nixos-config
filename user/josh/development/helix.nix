{ pkgs, ... }:
let
  writeTOML = (pkgs.formats.toml { }).generate;
  readTOML = path: (fromTOML (builtins.readFile path));
  overrideTheme = name: overrides: writeTOML "${name}.toml" ((readTOML "${pkgs.helix.src}/runtime/themes/${name}.toml") // overrides);
in
{
  xdg.configFile."helix/themes/monokai.toml".source = overrideTheme "monokai" {
    "ui.virtual.inlay-hint".fg = "#88846F";
    "ui.background" = { };
  };
  xdg.configFile."helix/languages.toml".source = writeTOML "languages.toml" {
    language = [{
      name = "nix";
      auto-format = true;
    }];
    language-server = {
      nil = {
        command = "nil";
        config.nil.formatting.command = [ "nixpkgs-fmt" ];
      };
    };
  };
  programs.helix = {
    enable = true;
    settings = {
      theme = "monokai";
      editor = {
        lsp = {
          display-inlay-hints = true;
        };
        true-color = true;
      };
    };
  };
}