{ ... }:
{
  services.dunst.settings = {
    global = {
      font = "Monospace-10";
      format = "%s\n%b";
      sort = true;
      indicate_hidden = true;
      bounce_freq = 0;
      show_age_threshold = 60;
      word_wrap = true;
      ignore_newline = false;
      geometry = "0x5-30+20";
      transparency = 15;
      idle_threshold = 120;
      monitor = 0;
      follow = "keyboard";
      sticky_history = true;
      line_height = 0;
      separator_height = 2;
      padding = 8;
      horizontal_padding = 8;
      separator_color = "frame";
      startup_notification = false;
      browser = "firefox -new-tab";
      frame_width = 3;
      frame_color = "#aaaaaa";
      timeout = 10;
    };
    urgency_low = {
      background = "#222222";
      foreground = "#ffffff";
    };
    urgency_normal = {
      background = "#285577";
      foreground = "#ffffff";
    };
    urgency_critical = {
      background = "#900000";
      foreground = "#ffffff";
    };
  };
}
