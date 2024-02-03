# This file is based on Ruby in nixpkgs.
# See: https://github.com/NixOS/nixpkgs/blob/c8c617e4735953976ec0048745894ceea090e2b2/pkgs/top-level/all-packages.nix#L17991
{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {inherit system;} }:

rec {  
    inherit (pkgs.callPackage ./pkgs/gemstone {})
      gemstone_3_6_1
      gemstone_3_6_2
      gemstone_3_6_3
      gemstone_3_6_4
      gemstone_3_6_5
      gemstone_3_6_6
      gemstone_3_6_8
      gemstone_3_7_0;
    gemstone_3_6 = gemstone_3_6_8;
    gemstone_3_7 = gemstone_3_7_0;
    gemstone = gemstone_3_7;
}
