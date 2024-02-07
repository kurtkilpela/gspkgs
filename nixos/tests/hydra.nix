{
  pkgs ? import <nixpkgs> {},
  gspkgs ? import ./../../default.nix { inherit pkgs; }
}:

(import ./default.nix { inherit pkgs; inherit gspkgs; }).gstests
