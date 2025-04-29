{ pkgs, lib, config, inputModules, ... }:
{
  imports = [
    ../common.nix
    ../josh/development
    ../josh/gpg.nix
    ../josh/git.nix
    ../josh/jujutsu
    ../josh/zellij.nix

    inputModules.private.default
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = [
    pkgs.devenv
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  home.activation = {
    installDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      [ ! -d $HOME/.config/emacs ] && \
        run git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs && \
        run $HOME/.config/emacs/bin/doom install --env --install --force
    '';
    syncDoom = lib.hm.dag.entryAfter [ "installDoom" ] ''
      run $HOME/.config/emacs/bin/doom sync
    '';
  };


  # programs.alacritty.settings.font.size = lib.mkForce 14;
}
