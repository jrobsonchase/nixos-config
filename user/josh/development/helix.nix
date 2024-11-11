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
    language = [
      {
        name = "nix";
        auto-format = true;
      }
      {
        name = "cpp";
        auto-format = true;
      }
    ];
    language-server = {
      nil = {
        command = "nil";
        config.nil.formatting.command = [ "nixpkgs-fmt" ];
      };
      clangd = {
        args = [ "--enable-config" ];
      };
    };
  };
  programs.helix = {
    enable = true;
    package = pkgs.helix-git;
    settings = {
      theme = "monokai";
      keys.normal.g.q = ":reflow";
      keys.select."0" = "goto_line_start";
      keys.select."$" = "goto_line_end_newline";
      keys.normal."0" = "goto_line_start";
      keys.normal."$" = "goto_line_end_newline";
      keys.normal."A-I" = ":toggle lsp.display-inlay-hints";
      editor = {
        line-number = "relative";
        lsp = {
          display-inlay-hints = true;
        };
        true-color = true;
      };
    };
  };
}
