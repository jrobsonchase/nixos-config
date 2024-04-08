{ pkgs, ... }:
let
  writeTOML = (pkgs.formats.toml { }).generate;
  readTOML = path: (fromTOML (builtins.readFile path));
  overrideTheme = name: overrides: writeTOML "${name}.toml" ((readTOML "${pkgs.helix.src}/runtime/themes/${name}.toml") // overrides);
in
{
  xdg.configFile."helix/themes/monokai.toml".source = overrideTheme "monokai" {
    "ui.virtual.inlay-hint".fg = "#88846F";
  };
  programs.helix = {
    enable = true;
    settings = {
      theme = "monokai";
      editor.lsp = {
        display-inlay-hints = true;
      };
    };
  };
}
