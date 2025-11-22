{
  lib,
  stdenv,
  fetchurl,
  godot-headless,
  godot-export-templates,
  writeShellScript,
}:

stdenv.mkDerivation rec {
  version = "0.9";
  name = "pixelorama-${version}";

  src = fetchurl {
    url = "https://github.com/Orama-Interactive/Pixelorama/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-bW1IVEKfrURAsPD1bBw5NhmJ+i0tDp+8R9U2bmuBjGg=";
  };

  buildPhase = ''
    export HOME="$(pwd)"

    mkdir -p .local/share/godot/
    ln -s "${godot-export-templates}/share/godot/templates" ".local/share/godot/templates"

    mkdir -p build
    godot-headless -v --export "Linux/X11 64-bit" ./build/pixelorama
    godot-headless -v --export-pack "Linux/X11 64-bit" ./build/pixelorama.pck
  '';

  installPhase = ''
    install -D -m 755 -t $out/libexec ./build/pixelorama
    install -D -m 644 -t $out/libexec ./build/pixelorama.pck
    install -D -m 644 -t $out/share/applications ./Misc/Linux/com.orama_interactive.Pixelorama.desktop

    install -d -m 755 $out/bin
    ln -s $out/libexec/pixelorama $out/bin/pixelorama
  '';

  nativeBuildInputs = [
    godot-headless
    godot-export-templates
  ];
}
