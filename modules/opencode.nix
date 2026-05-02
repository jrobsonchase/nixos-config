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
      '';

      streamCmd = pkgs.dockerTools.streamLayeredImage {
        name = "opencode";
        tag = "latest";
        contents = [ pkgs.opencode pkgs.bash pkgs.coreutils opencodeUserSetup ];
        config = {
          Entrypoint = [ "${pkgs.opencode}/bin/opencode" ];
          Cmd = [ "web" ];
          User = "opencode";
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
