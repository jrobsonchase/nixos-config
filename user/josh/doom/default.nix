{ pkgs, lib, config, ... }: {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [ vterm lsp-docker ];
  };

  home.file.".config/doom".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixpkgs/user/josh/doom";

  home.activation = {
    installDoom = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      [ ! -d $HOME/.config/emacs ] && \
        run git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs && \
        run $HOME/.config/emacs/bin/doom install --env --install --force
    '';
    syncDoom = lib.hm.dag.entryAfter [ "installDoom" ] ''
      run $HOME/.config/emacs/bin/doom sync
    '';
  };

  home.packages = with pkgs; [
    (lib.lowPrio nodejs)
    copilot-language-server
    yaml-language-server
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.config/emacs/bin"
  ];
}
