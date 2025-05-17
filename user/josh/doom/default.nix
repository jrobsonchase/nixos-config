{ pkgs, lib, config, ... }: {
  home.file.".config/doom".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixpkgs/user/josh/doom";

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
}
