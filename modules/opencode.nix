{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      opencodeUserSetup = pkgs.runCommand "opencode-user-setup" { } ''
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

      entrypoint = pkgs.writeShellScriptBin "entrypoint" ''
        mkdir -p /home/opencode/.config/opencode /home/opencode/.local
        chown -R opencode:opencode /home/opencode
        exec ${pkgs.gosu}/bin/gosu opencode ${pkgs.opencode}/bin/opencode "$@"
      '';

      streamCmd = pkgs.dockerTools.streamLayeredImage {
        name = "opencode";
        tag = "latest";
        contents = [ pkgs.opencode pkgs.bash pkgs.coreutils pkgs.gosu opencodeUserSetup entrypoint ];
        config = {
          Entrypoint = [ "/bin/entrypoint" ];
          Cmd = [ "web" ];
          Env = [ "HOME=/home/opencode" "USER=opencode" ];
        };
      };
    in
    {
      packages = {
        stream-opencode = pkgs.runCommand "stream-opencode" { } ''
          mkdir -p $out/bin
          ln -s ${streamCmd} $out/bin/stream-opencode
        '';
      };
    };
}
