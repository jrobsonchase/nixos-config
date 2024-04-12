{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_layout = "compact";
      pane_frames = false;
      theme = "monokai";
      themes.monokai = {
        bg = "#272822";
        fg = "#F8F8F2";
        black = "#272822";
        red = "#F92672";
        green = "#A6E22E";
        yellow = "#F4BF75";
        blue = "#66D9EF";
        magenta = "#AE81FF";
        cyan = "#A1EFE4";
        white = "#F8F8F2";
        orange = "#FD971F";
      };
    };
  };
}
