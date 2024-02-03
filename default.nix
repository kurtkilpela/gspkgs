# This file is based on Ruby in nixpkgs.
# See: https://github.com/NixOS/nixpkgs/blob/c8c617e4735953976ec0048745894ceea090e2b2/pkgs/top-level/all-packages.nix#L17991
{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {inherit system;} }:

let
  lib = pkgs.lib;
  gspkgs = pkgs.callPackage ./pkgs/gemstone {inherit system; inherit pkgs;};
  gsPkgNames = (builtins.filter (each: lib.strings.hasPrefix "gemstone" each) (builtins.attrNames gspkgs));
  supportedPkgNames = (builtins.filter (name: builtins.elem system gspkgs.${name}.meta.platforms) gsPkgNames);
  supportedPkgs = lib.foldl (acc: name: acc // { ${name} = gspkgs.${name}; } ) {} supportedPkgNames;
in
  supportedPkgs
  // rec {
    gemstone_3_6 = supportedPkgs.gemstone_3_6_8;
    gemstone_3_7 = supportedPkgs.gemstone_3_7_0;
    gemstone = gemstone_3_7;
  }

