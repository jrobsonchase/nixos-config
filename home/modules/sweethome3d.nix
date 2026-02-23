{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (symlinkJoin {
      name = "sweethome3d";
      paths = [ sweethome3d.application ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/sweethome3d \
          --prefix JAVA_TOOL_OPTIONS ' ' '-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true'
      '';
    })
  ];
}
