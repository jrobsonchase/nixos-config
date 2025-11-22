{
  stdenv,
  lib,
  fetchzip,
  udev,
  dbus,
  xorg,
  glibc,
  gnome,
  makeWrapper,
  libGL,
}:

let
  libs = [
    udev
    dbus
    libGL
  ]
  ++ (with xorg; [
    libX11
    libXcursor
    libXrandr
    libXi
  ]);

  buildInputs = libs ++ [
    gnome.zenity
  ];
in

stdenv.mkDerivation rec {
  name = "cryptowatch-desktop-${version}";

  version = "0.4.3";

  src = fetchzip {
    url = "https://cryptowat.ch/desktop/download/linux/${version}";
    sha256 = "sha256-vPq3gCdYm4MGmJ6ZGE8VtIaFNzXFNK+ypF2lI0fJntU=";
    extension = "zip";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  inherit buildInputs;

  sourceRoot = ".";

  installPhase = ''
    install -m755 -D ${src}/cryptowatch_desktop $out/libexec/cryptowatch_desktop
    makeWrapper $out/libexec/cryptowatch_desktop $out/bin/cryptowatch_desktop \
        --prefix PATH : ${lib.makeBinPath [ gnome.zenity ]} \
        ;
  '';

  postFixup = ''
    cryptowatch="$out/libexec/cryptowatch_desktop"
    oldrpath=$(patchelf --print-rpath "$cryptowatch")
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 "$cryptowatch"
    patchelf --set-rpath "$oldrpath:${lib.makeLibraryPath libs}" "$cryptowatch"
  '';

  meta = with lib; {
    homepage = "https://cryptowat.ch";
    description = "Cryptowatch Desktop Client";
    platforms = platforms.linux;
  };
}
