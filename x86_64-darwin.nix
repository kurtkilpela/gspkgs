{...}:

let
  system = "x86_64-darwin";
  pkgs = import <nixpkgs> { inherit system; };
in
import ./filter.nix {inherit system; inherit pkgs;}
