{ pkgs, ... }:
{
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
