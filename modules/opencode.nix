{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      streamCmd = pkgs.dockerTools.streamLayeredImage {
        name = "opencode";
        tag = "latest";
        contents = [ pkgs.opencode pkgs.bash pkgs.coreutils ];
        config = {
          Entrypoint = [ "${pkgs.opencode}/bin/opencode" ];
          Cmd = [ "web" ];
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
