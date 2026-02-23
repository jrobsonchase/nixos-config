{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "zedokai"
      "git-firefly"
      "toml"
      "html"
    ];
    userKeymaps = [
      {
        bindings = {
          alt-m = "collab::Mute";
        };
      }
    ];

    userSettings = {
      agent = {
        default_model = {
          provider = "copilot_chat";
          model = "gpt-4.1";
        };
        model_parameters = [ ];
      };
      audio = {
        "experimental.auto_microphone_volume" = true;
        "experimental.rodio_audio" = true;
      };
      autoscroll_on_clicks = true;
      base_keymap = "VSCode";
      buffer_font_family = "DejaVu Sans Mono";
      buffer_font_size = 14.0;
      buffer_line_height = "standard";
      calls = {
        mute_on_join = true;
      };
      colorize_brackets = true;
      current_line_highlight = "all";
      debugger = {
        dock = "right";
      };
      diagnostics = {
        inline = {
          padding = 4;
          enabled = true;
        };
      };
      disable_ai = false;
      edit_predictions = {
        provider = "copilot";
        mode = "subtle";
      };
      git = {
        inline_blame = {
          min_column = 25;
          padding = 10;
          delay_ms = 500;
        };
      };
      helix_mode = true;
      icon_theme = "Zed (Default)";
      indent_guides = {
        active_line_width = 1;
        background_coloring = "indent_aware";
        coloring = "indent_aware";
      };
      inlay_hints = {
        enabled = false;
        show_background = true;
      };
      languages = {
        Go = {
          language_servers = [
            "gopls"
            "golangci-lint"
          ];
        };
        Rust = { };
        YAML = {
          tab_size = 2;
        };
        Nix = {
          language_servers = [
            "!nil"
            "nixd"
          ];
        };
      };
      lsp = {
        yaml-language-server = {
          settings = {
            yaml = {
              customTags = [
                "!reference sequence"
              ];
            };
          };
        };
        rust-analyzer = {
          initialization_options = {
            check = {
              command = "clippy";
            };
          };
        };
        golangci-lint = {
          initialization_options = {
            command = [
              "golangci-lint"
              "run"
              "--out-format"
              "json"
              "--issues-exit-code=1"
            ];
          };
        };
      };
      lsp_document_colors = "inlay";
      minimap = {
        current_line_highlight = "all";
        thumb_border = "left_open";
        thumb = "always";
        show = "auto";
      };
      preferred_line_length = 100;
      prettier = {
        allowed = false;
      };
      relative_line_numbers = "enabled";
      redact_private_values = true;
      restore_on_startup = "last_session";
      rounded_selection = true;
      scroll_beyond_last_line = "vertical_scroll_margin";
      seed_search_query_from_cursor = "selection";
      search = {
        center_on_match = true;
        regex = true;
        case_sensitive = false;
      };
      soft_wrap = "prefer_line";
      sticky_scroll = {
        enabled = true;
      };
      theme = "Zedokai Darker Classic";
      theme_overrides = {
        "Zedokai Darker Classic" = {
          "terminal.ansi.blue" = "#268bd2";
          "terminal.ansi.bright_blue" = "#268bd2";
        };
      };
      toolbar = {
        agent_review = true;
      };
      ui_font_family = "DejaVu Sans";
      ui_font_size = 16.0;
      use_smartcase_search = true;
      vertical_scroll_margin = 10.0;
      vim_mode = false;
    };
  };
}
