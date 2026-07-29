{
  stdenv,
  fetchurl,
  ...
}:
let
  version = "0.2.396";
  hashes = {
    "linux" = {
      "x86_64" = "sha256-7hqbw17g98vy6uJrg8QBeTP+m4879uwXaC038aS0Z/k=";
    };
  };

  system = stdenv.hostPlatform.system;
  arch = builtins.elemAt (builtins.split "-" system) 0;
  os = builtins.elemAt (builtins.split "-" system) 2;
  mkUrl = os: arch: "https://dl.enforce.dev/chainctl/${version}/chainctl_${os}_${arch}";
  url = mkUrl os arch;
  sha256 = hashes.${os}.${arch};
in
stdenv.mkDerivation {
  inherit version;
  pname = "chainctl";

  src = fetchurl {
    inherit url sha256;
    name = "chainctl";
    executable = true;
  };

  phases = [
    "installPhase"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/chainctl
    ln -s $out/bin/chainctl $out/bin/docker-credential-cgr
  '';
}
