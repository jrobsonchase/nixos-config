{ pkgs, ... }:
{
  programs.alacritty = {
    settings = {
      env = {
        TERM = "xterm-256color";
        # WINIT_X11_SCALE_FACTOR = "1";
      };
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
          family = "Fira Code";
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
      keyboard.bindings = [
        {
          key = "N";
          mods = "Control|Shift";
          action = "SpawnNewInstance";
        }
        {
          key = "Paste";
          action = "Paste";
        }
        {
          key = "Copy";
          action = "Copy";
        }
        {
          key = "PageUp";
          mods = "Shift";
          action = "ScrollPageUp";
          mode = "~Alt";
        }
        {
          key = "PageDown";
          mods = "Shift";
          action = "ScrollPageDown";
          mode = "~Alt";
        }
        {
          key = "NumpadEnter";
          chars = "\\n";
        }
      ];
    };
  };
}
