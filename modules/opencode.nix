{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      entrypoint = pkgs.writeShellScriptBin "entrypoint" ''
        ${pkgs.coreutils}/bin/mkdir -p /home/opencode/.config/opencode
        ${pkgs.coreutils}/bin/chown -R opencode:opencode /home/opencode
        exec ${pkgs.shadow}/bin/su opencode -c "${pkgs.opencode}/bin/opencode $*"
      '';

      streamCmd = pkgs.dockerTools.streamLayeredImage {
        name = "opencode";
        tag = "latest";
        contents = [ pkgs.opencode pkgs.bash pkgs.coreutils pkgs.shadow entrypoint ];
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
