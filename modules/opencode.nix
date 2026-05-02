{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        opencode-image = pkgs.dockerTools.buildLayeredImage {
          name = "opencode";
          tag = "latest";
          contents = [ pkgs.opencode ];
        config = {
          Entrypoint = [ "${pkgs.opencode}/bin/opencode" "web" ];
        };
        };
      };
    };
}
