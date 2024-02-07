{
  pkgs ? import <nixpkgs> { config.allowUnfree=true; },
  gspkgs ? import ./../../default.nix { inherit pkgs; }
}:

(import ./default.nix { inherit pkgs; inherit gspkgs; }).gstests
