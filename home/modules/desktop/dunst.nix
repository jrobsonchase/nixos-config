{ ... }:
{
  services.dunst.settings = {
    global = {
      font = "Monospace-10";
      sort = true;
      indicate_hidden = true;
      show_age_threshold = 60;
      word_wrap = true;
      ignore_newline = false;
      transparency = 15;
      idle_threshold = 120;
      monitor = 0;
      follow = "keyboard";
      sticky_history = true;
      line_height = 0;
      separator_height = 2;
      horizontal_padding = 8;
      separator_color = "frame";
      startup_notification = false;
      browser = "firefox -new-tab";
      frame_width = 2;
      frame_color = "#d6d6d6";
      timeout = 20;
      corner_radius = 10;
      origin = "top-center";
      width = "(0, 500)";
      height = "(0, 200)";
      offset = "(0, 20)";
    };
    urgency_low = {
      background = "#222222";
      foreground = "#d6d6d6";
    };
    urgency_normal = {
      background = "#2e2e2e";
      foreground = "#d6d6d6";
    };
    urgency_critical = {
      background = "#900000";
      foreground = "#ffffff";
    };
  };
}
