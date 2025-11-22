{ lib, ... }:
with (import ../../lib/kdl.nix { inherit lib; });
let
  node0 = name: kdlNode name [ ] { } [ ];
  node1 = name: value: kdlNode name [ value ] { } [ ];
  nodeCh = name: children: kdlNode name [ ] { } children;
  bind = args: children: kdlNode "bind" args { } children;
  pane = props: children: kdlNode "pane" [ ] props children;
in
{
  xdg.configFile."zellij/layouts/helix.kdl".text = toKDL { } [
    (nodeCh "layout" [
      (kdlNode "tab" [ ] { hide_floating_panes = true; } [
        (pane {
          command = "hx";
          close_on_exit = true;
          borderless = true;
        } [ ])
        (nodeCh "floating_panes" [
          (pane { } [
            (node1 "x" "50%")
            (node1 "y" "50%")
          ])
        ])
        (pane
          {
            size = 1;
            borderless = true;
          }
          [
            (kdlNode "plugin" [ ] { location = "zellij:compact-bar"; } [ ])
          ]
        )
      ])
    ])
    (kdlNode "keybinds" [ ] { clear-defaults = true; } [
      (nodeCh "normal" [
        (bind "Alt `" (node0 "ToggleFloatingPanes"))
        (bind "Alt d" (node0 "Detach"))
      ])
    ])
  ];
  xdg.configFile."zellij/config.kdl".text = toKDL { } [
    (node1 "default_layout" "compact")
    (node1 "pane_frames" false)
    (node1 "theme" "monokai")
    (nodeCh "themes" [
      (nodeCh "monokai" [
        (node1 "bg" "#272822")
        (node1 "fg" "#F8F8F2")
        (node1 "black" "#272822")
        (node1 "red" "#F92672")
        (node1 "green" "#A6E22E")
        (node1 "yellow" "#F4BF75")
        (node1 "blue" "#66D9EF")
        (node1 "magenta" "#AE81FF")
        (node1 "cyan" "#A1EFE4")
        (node1 "white" "#F8F8F2")
        (node1 "orange" "#FD971F")
      ])
    ])
    (nodeCh "keybindings" [
      (nodeCh "locked" [
        (bind "Ctrl g" (node1 "SwitchToMode" "Normal"))
      ])
      (nodeCh "resize" [
        (bind "Ctrl n" (node1 "SwitchToMode" "Normal"))
        (bind [ "h" "Left" ] (node1 "Resize" "Increase Left"))
        (bind [ "j" "Down" ] (node1 "Resize" "Increase Down"))
        (bind [ "k" "Up" ] (node1 "Resize" "Increase Up"))
        (bind [ "l" "Right" ] (node1 "Resize" "Increase Right"))
        (bind "H" (node1 "Resize" "Decrease Left"))
        (bind "J" (node1 "Resize" "Decrease Down"))
        (bind "K" (node1 "Resize" "Decrease Up"))
        (bind "L" (node1 "Resize" "Decrease Right"))
        (bind [ "=" "+" ] (node1 "Resize" "Increase"))
        (bind "-" (node1 "Resize" "Decrease"))
      ])
      (nodeCh "pane" [
        (bind "Ctrl p" (node1 "SwitchToMode" "Normal"))
        (bind [ "h" "Left" ] (node1 "MoveFocus" "Left"))
        (bind [ "l" "Right" ] (node1 "MoveFocus" "Right"))
        (bind [ "j" "Down" ] (node1 "MoveFocus" "Down"))
        (bind [ "k" "Up" ] (node1 "MoveFocus" "Up"))
        (bind "p" (node0 "SwitchFocus"))
        (bind "n" [
          (node0 "NewPane")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "d" [
          (node1 "NewPane" "Down")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "r" [
          (node1 "NewPane" "Right")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "x" [
          (node0 "CloseFocus")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "f" [
          (node0 "ToggleFocusFullscreen")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "z" [
          (node0 "TogglePaneFrames")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "w" [
          (node0 "ToggleFloatingPanes")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "e" [
          (node0 "TogglePaneEmbedOrFloating")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "c" [
          (node1 "SwitchToMode" "RenamePane")
          (node1 "PaneNameInput" 0)
        ])
      ])
      (nodeCh "move" [
        (bind "Ctrl h" (node1 "SwitchToMode" "Normal"))
        (bind [ "n" "Tab" ] (node0 "MovePane"))
        (bind "p" (node0 "MovePaneBackwards"))
        (bind [ "h" "Left" ] (node1 "MovePane" "Left"))
        (bind [ "j" "Down" ] (node1 "MovePane" "Down"))
        (bind [ "k" "Up" ] (node1 "MovePane" "Up"))
        (bind [ "l" "Right" ] (node1 "MovePane" "Right"))
      ])
      (nodeCh "tab" [
        (bind "Ctrl t" (node1 "SwitchToMode" "Normal"))
        (bind "r" [
          (node1 "SwitchToMode" "RenameTab")
          (node1 "TabNameInput" 0)
        ])
        (bind [ "h" "Left" "Up" "k" ] (node0 "GoToPreviousTab"))
        (bind [ "l" "Right" "Down" "j" ] (node0 "GoToNextTab"))
        (bind "n" [
          (node0 "NewTab")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "x" [
          (node0 "CloseTab")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "s" [
          (node0 "ToggleActiveSyncTab")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "b" [
          (node0 "BreakPane")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "]" [
          (node0 "BreakPaneRight")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "[" [
          (node0 "BreakPaneLeft")
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "1" [
          (node1 "GoToTab" 1)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "2" [
          (node1 "GoToTab" 2)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "3" [
          (node1 "GoToTab" 3)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "4" [
          (node1 "GoToTab" 4)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "5" [
          (node1 "GoToTab" 5)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "6" [
          (node1 "GoToTab" 6)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "7" [
          (node1 "GoToTab" 7)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "8" [
          (node1 "GoToTab" 8)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "9" [
          (node1 "GoToTab" 9)
          (node1 "SwitchToMode" "Normal")
        ])
        (bind "Tab" (node0 "ToggleTab"))
      ])
      (nodeCh "scroll" [
        (bind [ "Ctrl s" ] [ (node1 "SwitchToMode" "Normal") ])
        (bind [ "e" ] [ (node0 "EditScrollback") (node1 "SwitchToMode" "Normal") ])
        (bind [ "s" ] [ (node1 "SwitchToMode" "EnterSearch") (node1 "SearchInput" 0) ])
        (bind [ "Ctrl c" ] [ (node0 "ScrollToBottom") (node1 "SwitchToMode" "Normal") ])
        (bind [ "j" "Down" ] [ (node0 "ScrollDown") ])
        (bind [ "k" "Up" ] [ (node0 "ScrollUp") ])
        (bind [ "Ctrl f" "PageDown" "Right" "l" ] (node0 "PageScrollDown"))
        (bind [ "Ctrl b" "PageUp" "Left" "h" ] (node0 "PageScrollUp"))
        (bind [ "d" ] (node0 "HalfPageScrollDown"))
        (bind [ "u" ] (node0 "HalfPageScrollUp"))
        # uncomment this and adjust key if using copy_on_select=false
        # (bind "Alt c" (node0  "Copy") )
      ])
      (nodeCh "search" [
        (bind [ "Ctrl s" ] [ (node1 "SwitchToMode" "Normal") ])
        (bind [ "Ctrl c" ] [ (node0 "ScrollToBottom") (node1 "SwitchToMode" "Normal") ])
        (bind [ "j" "Down" ] [ (node0 "ScrollDown") ])
        (bind [ "k" "Up" ] [ (node0 "ScrollUp") ])
        (bind [ "Ctrl f" "PageDown" "Right" "l" ] (node0 "PageScrollDown"))
        (bind [ "Ctrl b" "PageUp" "Left" "h" ] (node0 "PageScrollUp"))
        (bind [ "d" ] [ (node0 "HalfPageScrollDown") ])
        (bind [ "u" ] [ (node0 "HalfPageScrollUp") ])
        (bind [ "n" ] [ (node1 "Search" "down") ])
        (bind [ "p" ] [ (node1 "Search" "up") ])
        (bind [ "c" ] [ (node1 "SearchToggleOption" "CaseSensitivity") ])
        (bind [ "w" ] [ (node1 "SearchToggleOption" "Wrap") ])
        (bind [ "o" ] [ (node1 "SearchToggleOption" "WholeWord") ])
      ])
      (nodeCh "entersearch" [
        (bind [ "Ctrl c" "Esc" ] [ (node1 "SwitchToMode" "Scroll") ])
        (bind [ "Enter" ] [ (node1 "SwitchToMode" "Search") ])
      ])
      (nodeCh "renametab" [
        (bind [ "Ctrl c" ] [ (node1 "SwitchToMode" "Normal") ])
        (bind [ "Esc" ] [ (node0 "UndoRenameTab") (node1 "SwitchToMode" "Tab") ])
      ])
      (nodeCh "renamepane" [
        (bind "Ctrl c" (node1 "SwitchToMode" "Normal"))
        (bind "Esc" [
          (node0 "UndoRenamePane")
          (node1 "SwitchToMode" "Pane")
        ])
      ])
      (nodeCh "session" [
        (bind "Ctrl o" (node1 "SwitchToMode" "Normal"))
        (bind "Ctrl s" (node1 "SwitchToMode" "Scroll"))
        (bind "d" (node0 "Detach"))
        (bind "w" [
          (kdlNode "LaunchOrFocusPlugin" "session-manager" { } [
            (node1 "floating" true)
            (node1 "move_to_focused_tab" true)
          ])
          (node1 "SwitchToMode" "Normal")
        ])
      ])
      (nodeCh "tmux" [
        (bind [ "[" ] [ (node1 "SwitchToMode" "Scroll") ])
        (bind [ "Ctrl b" ] [ (node1 "Write" 2) (node1 "SwitchToMode" "Normal") ])
        (bind [ "\"" ] [ (node1 "NewPane" "Down") (node1 "SwitchToMode" "Normal") ])
        (bind [ "%" ] [ (node1 "NewPane" "Right") (node1 "SwitchToMode" "Normal") ])
        (bind [ "z" ] [ (node0 "ToggleFocusFullscreen") (node1 "SwitchToMode" "Normal") ])
        (bind [ "c" ] [ (node0 "NewTab") (node1 "SwitchToMode" "Normal") ])
        (bind [ "," ] [ (node1 "SwitchToMode" "RenameTab") ])
        (bind [ "p" ] [ (node0 "GoToPreviousTab") (node1 "SwitchToMode" "Normal") ])
        (bind [ "n" ] [ (node0 "GoToNextTab") (node1 "SwitchToMode" "Normal") ])
        (bind [ "Left" ] [ (node1 "MoveFocus" "Left") (node1 "SwitchToMode" "Normal") ])
        (bind [ "Right" ] [ (node1 "MoveFocus" "Right") (node1 "SwitchToMode" "Normal") ])
        (bind [ "Down" ] [ (node1 "MoveFocus" "Down") (node1 "SwitchToMode" "Normal") ])
        (bind [ "Up" ] [ (node1 "MoveFocus" "Up") (node1 "SwitchToMode" "Normal") ])
        (bind [ "h" ] [ (node1 "MoveFocus" "Left") (node1 "SwitchToMode" "Normal") ])
        (bind [ "l" ] [ (node1 "MoveFocus" "Right") (node1 "SwitchToMode" "Normal") ])
        (bind [ "j" ] [ (node1 "MoveFocus" "Down") (node1 "SwitchToMode" "Normal") ])
        (bind [ "k" ] [ (node1 "MoveFocus" "Up") (node1 "SwitchToMode" "Normal") ])
        (bind [ "o" ] [ (node0 "FocusNextPane") ])
        (bind [ "d" ] (node0 "Detach"))
        (bind [ "Space" ] [ (node0 "NextSwapLayout") ])
        (bind [ "x" ] [ (node0 "CloseFocus") (node1 "SwitchToMode" "Normal") ])
      ])
      (kdlNode "shared_except" "locked" { } [
        (bind [ "Ctrl g" ] [ (node1 "SwitchToMode" "Locked") ])
        (bind [ "Ctrl q" ] [ (node0 "Quit") ])
        (bind [ "Alt n" ] [ (node0 "NewPane") ])
        (bind [ "Alt i" ] [ (node1 "MoveTab" "Left") ])
        (bind [ "Alt o" ] [ (node1 "MoveTab" "Right") ])
        (bind [ "Alt h" "Alt Left" ] [ (node1 "MoveFocusOrTab" "Left") ])
        (bind [ "Alt l" "Alt Right" ] [ (node1 "MoveFocusOrTab" "Right") ])
        (bind [ "Alt j" "Alt Down" ] [ (node1 "MoveFocus" "Down") ])
        (bind [ "Alt k" "Alt Up" ] [ (node1 "MoveFocus" "Up") ])
        (bind [ "Alt =" "Alt +" ] [ (node1 "Resize" "Increase") ])
        (bind [ "Alt -" ] [ (node1 "Resize" "Decrease") ])
        (bind [ "Alt [" ] [ (node0 "PreviousSwapLayout") ])
        (bind [ "Alt ]" ] [ (node0 "NextSwapLayout") ])
      ])
      (kdlNode "shared_except" [ "normal" "locked" ] { } [
        (bind [ "Enter" "Esc" ] (node1 "SwitchToMode" "Normal"))
      ])
      (kdlNode "shared_except" [ "pane" "locked" ] { } [
        (bind "Ctrl p" (node1 "SwitchToMode" "Pane"))
      ])
      (kdlNode "shared_except" [ "resize" "locked" ] { } [
        (bind "Ctrl n" (node1 "SwitchToMode" "Resize"))
      ])
      (kdlNode "shared_except" [ "scroll" "locked" ] { } [
        (bind "Ctrl s" (node1 "SwitchToMode" "Scroll"))
      ])
      (kdlNode "shared_except" [ "session" "locked" ] { } [
        (bind "Ctrl o" (node1 "SwitchToMode" "Session"))
      ])
      (kdlNode "shared_except" [ "tab" "locked" ] { } [
        (bind "Ctrl t" (node1 "SwitchToMode" "Tab"))
      ])
      (kdlNode "shared_except" [ "move" "locked" ] { } [
        (bind "Ctrl h" (node1 "SwitchToMode" "Move"))
      ])
      (kdlNode "shared_except" [ "tmux" "locked" ] { } [
        (bind "Ctrl b" (node1 "SwitchToMode" "Tmux"))
      ])
    ])
  ];
  programs.zellij = {
    enable = true;
  };
}
