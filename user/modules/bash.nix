{ pkgs, ... }:
let
  setPs1 =
    let
      tput = "${pkgs.ncurses}/bin/tput";
    in
    ''
      BOLD="\[$(${tput} bold)\]"
      RED="\[$(${tput} setaf 1)\]"
      GREEN="\[$(${tput} setaf 2)\]"
      BLUE="\[$(${tput} setaf 4)\]"
      RESET="\[$(${tput} sgr0)\]"

      set_ps1() {
        if command -v ps1_ngrok_env >/dev/null; then
          PS1="$BOLD$GREEN\\u@\\h $(ps1_ngrok_env)$BOLD$BLUE\\W \\\$ $RESET"
        else
          PS1="$BOLD$GREEN\\u@\\h $BOLD$BLUE\\W \\\$ $RESET"
        fi
      }

      if [ -z "''${PROMPT_COMMAND:-}" ]; then
        PROMPT_COMMAND=set_ps1
      else
        PROMPT_COMMAND="set_ps1;''${PROMPT_COMMAND}"
      fi

      NGROK_SKIP_PS1=1
    '';
in
{
  programs.bash = {
    enable = true;
    enableVteIntegration = true;
    historyControl = [
      "erasedups"
      "ignorespace"
    ];
    initExtra = ''
      source <(gt completion)
      ${setPs1}
    '';
    shellAliases = {
      cp = "cp --reflink=auto --sparse=always";
      ls = "ls --color=auto";
      grep = "grep --colour=auto";
    };
    sessionVariables = {
      EDITOR = "vim";

      LESS_TERMCAP_mb = "$(printf \"\\e[1;31m\")";
      LESS_TERMCAP_md = "$(printf \"\\e[1;38;5;74m\")";
      LESS_TERMCAP_me = "$(printf \"\\e[0m\")";
      LESS_TERMCAP_se = "$(printf \"\\e[0m\")";
      LESS_TERMCAP_so = "$(printf \"\\e[38;5;246m\")";
      LESS_TERMCAP_ue = "$(printf \"\\e[0m\")";
      LESS_TERMCAP_us = "$(printf \"\\e[04;38;5;146m\")";
    };
  };
}
