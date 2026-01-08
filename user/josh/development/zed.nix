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
      seed_search_query_from_cursor = "selection";
      use_smartcase_search = true;
      search = {
        center_on_match = true;
        regex = true;
        case_sensitive = false;
      };
      prettier = {
        allowed = false;
      };
      lsp_document_colors = "inlay";
      inlay_hints = {
        enabled = false;
        show_background = true;
      };
      preferred_line_length = 100;
      soft_wrap = "prefer_line";
      toolbar = {
        agent_review = true;
      };
      sticky_scroll = {
        enabled = true;
      };
      autoscroll_on_clicks = true;
      vertical_scroll_margin = 10.0;
      scroll_beyond_last_line = "vertical_scroll_margin";
      rounded_selection = true;
      current_line_highlight = "all";
      buffer_line_height = "standard";
      audio = {
        "experimental.auto_microphone_volume" = true;
        "experimental.rodio_audio" = true;
      };
      calls = {
        mute_on_join = true;
      };
      indent_guides = {
        active_line_width = 1;
        background_coloring = "indent_aware";
        coloring = "indent_aware";
      };
      colorize_brackets = true;
      restore_on_startup = "last_session";
      diagnostics = {
        inline = {
          padding = 4;
          enabled = true;
        };
      };
      minimap = {
        current_line_highlight = "all";
        thumb_border = "left_open";
        thumb = "always";
        show = "auto";
      };
      icon_theme = "Zed (Default)";
      relative_line_numbers = "enabled";
      features = {
        edit_prediction_provider = "copilot";
      };
      edit_predictions = {
        mode = "subtle";
      };
      debugger = {
        dock = "right";
      };
      git = {
        inline_blame = {
          min_column = 25;
          padding = 10;
          delay_ms = 500;
        };
      };
      helix_mode = true;
      vim_mode = false;
      base_keymap = "VSCode";
      ui_font_family = "DejaVu Sans";
      buffer_font_family = "DejaVu Sans Mono";
      redact_private_values = true;
      agent = {
        default_model = {
          provider = "copilot_chat";
          model = "gpt-4.1";
        };
        model_parameters = [ ];
      };
      disable_ai = false;
      ui_font_size = 16.0;
      buffer_font_size = 14.0;
      theme = "Zedokai Darker Classic";
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
      theme_overrides = {
        "Zedokai Darker Classic" = {
          "terminal.ansi.blue" = "#268bd2";
          "terminal.ansi.bright_blue" = "#268bd2";
        };
      };
    };
  };
}
