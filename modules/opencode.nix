{ ... }:
{
  perSystem =
    { pkgs, ... }:
    with pkgs;
    let
      opencodeUserSetup = runCommand "opencode-user-setup" { } ''
        mkdir -p $out/etc $out/home/opencode/.config/opencode

        cat > $out/etc/passwd <<EOF
        root:x:0:0:root:/root:/bin/bash
        opencode:x:1000:1000:opencode:/home/opencode:/bin/bash
        EOF

        cat > $out/etc/group <<EOF
        root:x:0:
        opencode:x:1000:
        EOF

        cat > $out/etc/shadow <<EOF
        root:!:1:::::::
        opencode:!:1:::::::
        EOF
      '';

      entrypoint = writeShellScriptBin "entrypoint" ''
        mkdir -p /usr
        ln -s /bin /usr/bin
        mkdir -p /home/opencode/.config/opencode /home/opencode/.local /home/opencode/work
        chown -R opencode:opencode /home/opencode
        ${gosu}/bin/gosu opencode ${opencode}/bin/opencode "$@"
      '';

      streamCmd = dockerTools.streamLayeredImage {
        name = "opencode";
        tag = "latest";
        contents = [
          opencode
          mdbook
          mdbook-mermaid
          bash
          coreutils
          gnused
          gnugrep
          gawk
          findutils
          gosu
          nodejs
          python3
          bun
          git
          dockerTools.caCertificates
          opencodeUserSetup
          entrypoint
        ];
        config = {
          Entrypoint = [ "/bin/entrypoint" ];
          Cmd = [ "web" ];
          WorkingDir = "/home/opencode/work";
          Env = [
            "HOME=/home/opencode"
            "USER=opencode"
          ];
        };
      };
    in
    {
      packages = {
        stream-opencode = runCommand "stream-opencode" { } ''
          mkdir -p $out/bin
          ln -s ${streamCmd} $out/bin/stream-opencode
        '';
      };
    };
}
