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
    owner = "seam345";
    repo = pname;
    rev = "2266b8e";
    sha256 = "sha256-chQOOSa8L8/AnVTOn/a/lk86nTVrzGfuVbS5R8hfvDg=";
  };

  cargoSha256 = "sha256-zz7WZmrnkHctl6x/+UMSz90SlkqErH+XFTQV12ie7Tk=";


#  meta = with lib; {
#    description = "A utility that combines the usability of The Silver Searcher with the raw speed of grep";
#    homepage = "https://github.com/BurntSushi/ripgrep";
#    license = with licenses; [ unlicense /* or */ mit ];
#    maintainers = with maintainers; [ tailhook globin ma27 zowoq ];
#    mainProgram = "rg";
#  };
}
