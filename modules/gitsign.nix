{
  inputs,
  ...
}:
{
  flake.homeModules.gitsign =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      home.packages = with pkgs; [
        gitsign
        (pkgs.writeShellScriptBin "setup-gitsign" ''
          ${lib.optionalString config.programs.jujutsu.enable ''
            jj config set --repo signing.behavior drop
            jj config set --repo signing.backend gpgsm
            jj config set --repo signing.backends.gpgsm.program gitsign
            jj config set --repo git.write-change-id-header false
            jj config set --repo git.sign-on-push true
          ''}

          git config --local commit.gpgsign true  # Sign all commits
          git config --local tag.gpgsign true  # Sign all tags
          git config --local gpg.x509.program gitsign  # Use Gitsign for signing
          git config --local gpg.format x509  # Gitsign expects x509 args
        '')
      ];
      systemd.user.services.gitsign-credential-cache = {
        Unit = {
          Description = "GitSign credential cache";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.gitsign}/bin/gitsign-credential-cache";
        };
      };
      systemd.user.sockets.gitsign-credential-cache = {
        Unit = {
          Description = "GitSign credential cache";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Socket = {
          ListenStream = "%C/sigstore/gitsign/cache.sock";
          DirectoryMode = "0700";
        };
      };
      home.sessionVariables = {
        GITSIGN_CREDENTIAL_CACHE = "${config.xdg.cacheHome}/sigstore/gitsign/cache.sock";
      };
    };
}
