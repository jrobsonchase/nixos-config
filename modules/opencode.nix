{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        opencode-image = pkgs.dockerTools.streamLayeredImage {
          name = "opencode";
          tag = "latest";
          contents = [ pkgs.opencode pkgs.bash pkgs.coreutils ];
          config = {
            Entrypoint = [ "${pkgs.opencode}/bin/opencode" ];
            Cmd = [ "web" ];
          };
        };
      };
    };
}
