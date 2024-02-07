{
  pkgs ? import <nixpkgs> {},
  gspkgs ? import ./../../default.nix { inherit pkgs; }
}:

let
  gsPkgNames = (builtins.filter (each: lib.strings.hasPrefix "gemstone" each) (builtins.attrNames gspkgs));
  lib = pkgs.lib;
in
{
  gstests = lib.foldl (acc: name: acc // (import ./ensure-services-run.nix { inherit pkgs; inherit gspkgs; gemstone-package-name = name; })) {} gsPkgNames;
}
