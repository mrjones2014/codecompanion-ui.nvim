{ self, pkgs, ... }:
pkgs.runCommand "selene"
  {
    nativeBuildInputs = [ pkgs.selene ];
  }
  ''
    selene ${self}/lua --config ${self}/selene.toml
    touch $out
  ''
