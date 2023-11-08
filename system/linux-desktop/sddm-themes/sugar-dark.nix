{ pkgs }:

#let
#  image = pkgs.fetchurl {
#    url =
#      "https://github.com/tbreslein/wallpapers/blob/master/gruvbox/penguin.jpg?raw=true";
#    sha256 = "rTE57xA9FD6AuUCRH3HKJhXDNwm5fu4WMBeW9ocUM+A=";
#  };
#in
let image = ./penguin.jpg;
in pkgs.stdenv.mkDerivation {
  name = "sddm-sugar-candy";
  src = pkgs.fetchFromGitHub {
    owner = "MarianArlt";
    repo = "sddm-sugar-dark";
    rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
    sha256 = "flOspjpYezPvGZ6b4R/Mr18N7N3JdytCSwwu6mf4owQ=";
  };
  # installPhase = ''
  #   mkdir -p $out
  #   cp -R ./* $out/
  # '';
  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
    rm $out/Background.jpg
    cp -r ${image} $out/Background.jpg
  '';
}
