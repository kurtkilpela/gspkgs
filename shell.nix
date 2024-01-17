{ pkgs ? import <nixpkgs> {} }:

let
  gs = import ./default.nix {};
in
pkgs.mkShell {
  nativeBuildInputs = [ gs.gemstone ];
  
}
