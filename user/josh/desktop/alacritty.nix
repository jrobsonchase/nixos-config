{ pkgs, ... }:
{
  programs.alacritty = {
    settings = {
      env.TERM = "xterm-256color";
      window = {
        dimensions = {
          lines = 0;
          columns = 0;
        };
        padding = {
          x = 0;
          y = 0;
        };
        dynamic_padding = false;
        decorations = "full";
        startup_mode = "Windowed";
        dynamic_title = true;
        opacity = 0.95;
      };
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      font = {
        normal = {
          family = "terminal";
        };
        size = 12.0;
        offset = {
          x = 0;
          y = 0;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
      };
      # Monokai Dark
      colors = {
        draw_bold_text_with_bright_colors = true;

        # Default colors
        primary = {
          background = "0x272822";
          foreground = "0xF8F8F2";
        };

        # Normal colors
        normal = {
          black = "0x272822";
          red = "0xF92672";
          green = "0xA6E22E";
          yellow = "0xF4BF75";
          blue = "0x66D9EF";
          magenta = "0xAE81FF";
          cyan = "0xA1EFE4";
          white = "0xF8F8F2";
        };

        # Bright colors
        bright = {
          black = "0x75715E";
          red = "0xF92672";
          green = "0xA6E22E";
          yellow = "0xF4BF75";
          blue = "0x66D9EF";
          magenta = "0xAE81FF";
          cyan = "0xA1EFE4";
          white = "0xF9F8F5";
        };
      };
      bell = {
        animation = "EaseOutExpo";
        duration = 0;
        color = "0xffffff";
      };


      mouse = {
        bindings = [
          {
            mouse = "Middle";
            action = "PasteSelection";
          }
        ];
        hide_when_typing = false;
      };
      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";
        save_to_clipboard = true;
      };
      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };
      terminal.shell = {
        program = "${pkgs.bashInteractive}/bin/bash";
        args = [ "-l" ];
      };
      working_directory = "None";
      debug = {
        render_timer = false;
        persistent_logging = false;
        log_level = "Warn";
        print_events = false;
      };
      # Do I actually use any of these? Or is it just default?
      # Ported from my old config.
      keyboard.bindings = [
        { key = "N"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
        { key = "Paste"; action = "Paste"; }
        { key = "Copy"; action = "Copy"; }
        { key = "L"; mods = "Control"; action = "ClearLogNotice"; }
        { key = "L"; mods = "Control"; chars = "\\u000C"; }
        { key = "Home"; mods = "Alt"; chars = "\\u001b[1;3H"; }
        { key = "Home"; chars = "\\u001bOH"; mode = "AppCursor"; }
        { key = "Home"; chars = "\\u001b[H"; mode = "~AppCursor"; }
        { key = "End"; mods = "Alt"; chars = "\\u001b[1;3F"; }
        { key = "End"; chars = "\\u001bOF"; mode = "AppCursor"; }
        { key = "End"; chars = "\\u001b[F"; mode = "~AppCursor"; }
        { key = "PageUp"; mods = "Shift"; action = "ScrollPageUp"; mode = "~Alt"; }
        { key = "PageUp"; mods = "Shift"; chars = "\\u001b[5;2~"; mode = "Alt"; }
        { key = "PageUp"; mods = "Control"; chars = "\\u001b[5;5~"; }
        { key = "PageUp"; mods = "Alt"; chars = "\\u001b[5;3~"; }
        { key = "PageUp"; chars = "\\u001b[5~"; }
        { key = "PageDown"; mods = "Shift"; action = "ScrollPageDown"; mode = "~Alt"; }
        { key = "PageDown"; mods = "Shift"; chars = "\\u001b[6;2~"; mode = "Alt"; }
        { key = "PageDown"; mods = "Control"; chars = "\\u001b[6;5~"; }
        { key = "PageDown"; mods = "Alt"; chars = "\\u001b[6;3~"; }
        { key = "PageDown"; chars = "\\u001b[6~"; }
        { key = "Tab"; mods = "Shift"; chars = "\\u001b[Z"; }
        { key = "Back"; chars = "\\u007f"; }
        { key = "Back"; mods = "Alt"; chars = "\\u001b\\u007f"; }
        { key = "Insert"; chars = "\\u001b[2~"; }
        { key = "Delete"; chars = "\\u001b[3~"; }
        { key = "Left"; mods = "Shift"; chars = "\\u001b[1;2D"; }
        { key = "Left"; mods = "Control"; chars = "\\u001b[1;5D"; }
        { key = "Left"; mods = "Alt"; chars = "\\u001b[1;3D"; }
        { key = "Left"; chars = "\\u001b[D"; mode = "~AppCursor"; }
        { key = "Left"; chars = "\\u001bOD"; mode = "AppCursor"; }
        { key = "Right"; mods = "Shift"; chars = "\\u001b[1;2C"; }
        { key = "Right"; mods = "Control"; chars = "\\u001b[1;5C"; }
        { key = "Right"; mods = "Alt"; chars = "\\u001b[1;3C"; }
        { key = "Right"; chars = "\\u001b[C"; mode = "~AppCursor"; }
        { key = "Right"; chars = "\\u001bOC"; mode = "AppCursor"; }
        { key = "Up"; mods = "Shift"; chars = "\\u001b[1;2A"; }
        { key = "Up"; mods = "Control"; chars = "\\u001b[1;5A"; }
        { key = "Up"; mods = "Alt"; chars = "\\u001b[1;3A"; }
        { key = "Up"; chars = "\\u001b[A"; mode = "~AppCursor"; }
        { key = "Up"; chars = "\\u001bOA"; mode = "AppCursor"; }
        { key = "Down"; mods = "Shift"; chars = "\\u001b[1;2B"; }
        { key = "Down"; mods = "Control"; chars = "\\u001b[1;5B"; }
        { key = "Down"; mods = "Alt"; chars = "\\u001b[1;3B"; }
        { key = "Down"; chars = "\\u001b[B"; mode = "~AppCursor"; }
        { key = "Down"; chars = "\\u001bOB"; mode = "AppCursor"; }
        { key = "F1"; chars = "\\u001bOP"; }
        { key = "F2"; chars = "\\u001bOQ"; }
        { key = "F3"; chars = "\\u001bOR"; }
        { key = "F4"; chars = "\\u001bOS"; }
        { key = "F5"; chars = "\\u001b[15~"; }
        { key = "F6"; chars = "\\u001b[17~"; }
        { key = "F7"; chars = "\\u001b[18~"; }
        { key = "F8"; chars = "\\u001b[19~"; }
        { key = "F9"; chars = "\\u001b[20~"; }
        { key = "F10"; chars = "\\u001b[21~"; }
        { key = "F11"; chars = "\\u001b[23~"; }
        { key = "F12"; chars = "\\u001b[24~"; }
        { key = "F1"; mods = "Shift"; chars = "\\u001b[1;2P"; }
        { key = "F2"; mods = "Shift"; chars = "\\u001b[1;2Q"; }
        { key = "F3"; mods = "Shift"; chars = "\\u001b[1;2R"; }
        { key = "F4"; mods = "Shift"; chars = "\\u001b[1;2S"; }
        { key = "F5"; mods = "Shift"; chars = "\\u001b[15;2~"; }
        { key = "F6"; mods = "Shift"; chars = "\\u001b[17;2~"; }
        { key = "F7"; mods = "Shift"; chars = "\\u001b[18;2~"; }
        { key = "F8"; mods = "Shift"; chars = "\\u001b[19;2~"; }
        { key = "F9"; mods = "Shift"; chars = "\\u001b[20;2~"; }
        { key = "F10"; mods = "Shift"; chars = "\\u001b[21;2~"; }
        { key = "F11"; mods = "Shift"; chars = "\\u001b[23;2~"; }
        { key = "F12"; mods = "Shift"; chars = "\\u001b[24;2~"; }
        { key = "F1"; mods = "Control"; chars = "\\u001b[1;5P"; }
        { key = "F2"; mods = "Control"; chars = "\\u001b[1;5Q"; }
        { key = "F3"; mods = "Control"; chars = "\\u001b[1;5R"; }
        { key = "F4"; mods = "Control"; chars = "\\u001b[1;5S"; }
        { key = "F5"; mods = "Control"; chars = "\\u001b[15;5~"; }
        { key = "F6"; mods = "Control"; chars = "\\u001b[17;5~"; }
        { key = "F7"; mods = "Control"; chars = "\\u001b[18;5~"; }
        { key = "F8"; mods = "Control"; chars = "\\u001b[19;5~"; }
        { key = "F9"; mods = "Control"; chars = "\\u001b[20;5~"; }
        { key = "F10"; mods = "Control"; chars = "\\u001b[21;5~"; }
        { key = "F11"; mods = "Control"; chars = "\\u001b[23;5~"; }
        { key = "F12"; mods = "Control"; chars = "\\u001b[24;5~"; }
        { key = "F1"; mods = "Alt"; chars = "\\u001b[1;6P"; }
        { key = "F2"; mods = "Alt"; chars = "\\u001b[1;6Q"; }
        { key = "F3"; mods = "Alt"; chars = "\\u001b[1;6R"; }
        { key = "F4"; mods = "Alt"; chars = "\\u001b[1;6S"; }
        { key = "F5"; mods = "Alt"; chars = "\\u001b[15;6~"; }
        { key = "F6"; mods = "Alt"; chars = "\\u001b[17;6~"; }
        { key = "F7"; mods = "Alt"; chars = "\\u001b[18;6~"; }
        { key = "F8"; mods = "Alt"; chars = "\\u001b[19;6~"; }
        { key = "F9"; mods = "Alt"; chars = "\\u001b[20;6~"; }
        { key = "F10"; mods = "Alt"; chars = "\\u001b[21;6~"; }
        { key = "F11"; mods = "Alt"; chars = "\\u001b[23;6~"; }
        { key = "F12"; mods = "Alt"; chars = "\\u001b[24;6~"; }
        { key = "F1"; mods = "Super"; chars = "\\u001b[1;3P"; }
        { key = "F2"; mods = "Super"; chars = "\\u001b[1;3Q"; }
        { key = "F3"; mods = "Super"; chars = "\\u001b[1;3R"; }
        { key = "F4"; mods = "Super"; chars = "\\u001b[1;3S"; }
        { key = "F5"; mods = "Super"; chars = "\\u001b[15;3~"; }
        { key = "F6"; mods = "Super"; chars = "\\u001b[17;3~"; }
        { key = "F7"; mods = "Super"; chars = "\\u001b[18;3~"; }
        { key = "F8"; mods = "Super"; chars = "\\u001b[19;3~"; }
        { key = "F9"; mods = "Super"; chars = "\\u001b[20;3~"; }
        { key = "F10"; mods = "Super"; chars = "\\u001b[21;3~"; }
        { key = "F11"; mods = "Super"; chars = "\\u001b[23;3~"; }
        { key = "F12"; mods = "Super"; chars = "\\u001b[24;3~"; }
        { key = "NumpadEnter"; chars = "\\n"; }
      ];
    };
  };
}
