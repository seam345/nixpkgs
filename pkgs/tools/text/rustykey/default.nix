{ lib
, pkgs
, stdenv
, fetchFromGitLab
, rustPlatform
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "rustykey";
  version = "v0.40";

   nativeBuildInputs = [
    # for block-utils, to mount the device with the salt on
    pkgs.pkg-config
  ];
  buildInputs = [
    pkgs.openssl # for sha2 digest
    # for block-utils, to mount the device with the salt on
    pkgs.systemd
  ];

#  src = /home/sean/GitDirs/Gitlab/Seam345/rustykey;
  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "roryjson";
    repo = pname;
    rev = "issue39-touch-timeout";
    sha256 = "sha256-PUUMZ2u+nEYkUfp7MzXYBzmF6+Cf4MNKPN3kK58Lj2U=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "yubico_manager-0.9.0" = "sha256-3wp6sdtJ5GWitG/wFv+X36fqNW9jXNaNpEPGsuuN1rU=";
    };
  };


#  cargoHash = "";
#  cargoSha256 = "sha256-zz7WZmrnkHctl6x/+UMSz90SlkqErH+XFTQV12ie7Tk=";
#  cargoHash = "sha256-l6E+6CUBwptqpaAFIqhivvlMWWBnFdSXuO8nJQofccc=";


#  meta = with lib; {
#    description = "A utility that combines the usability of The Silver Searcher with the raw speed of grep";
#    homepage = "https://github.com/BurntSushi/ripgrep";
#    license = with licenses; [ unlicense /* or */ mit ];
#    maintainers = with maintainers; [ tailhook globin ma27 zowoq ];
#    mainProgram = "rg";
#  };
}
