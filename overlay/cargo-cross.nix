{ lib
, rustPlatform
, rustup
, fetchFromGitHub
, fetchpatch
, nix-update-script
, makeWrapper
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-cross";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "cross-rs";
    repo = "cross";
    rev = "v${version}";
    sha256 = "sha256-gaY34ziC+ugw/HUTSh0Uk5WBfWMRZLybfpAMkUzsj8g=";
  };

  cargoSha256 = "sha256-bdcdlnNr4CdkIJNoo8tb4ohVDmAcKIOP0nRr6BM+EPw=";
  # cargoSha256 = lib.fakeSha256;

  # Fixes https://github.com/cross-rs/cross/issues/943
  cargoPatches = [
    (fetchpatch {
      url = "https://github.com/cross-rs/cross/commit/d639578881d21d28d91d155722201cc53b00c5e7.patch";
      sha256 = "sha256-FWaYIEMonb1Z8g5yXfd/Rl/LnxSYVwLfFIvPY1mJNxU=";
    })
  ];

  passthru = {
    updateScript = nix-update-script {
      attrPath = pname;
    };
  };

  postInstall = ''
    wrapProgram $out/bin/cross --prefix PATH : ${rustup}/bin
  '';

  meta = with lib; {
    description = "Zero setup cross compilation and cross testing";
    homepage = "https://github.com/cross-rs/cross";
    license = with licenses; [ asl20 /* or */ mit ];
    maintainers = with maintainers; [ otavio ];
    mainProgram = "cross";
  };
}
