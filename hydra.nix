# Enable unfree packages while running in hyrda
{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {config.allowUnfree=true; inherit system;} }:
import ./default.nix { inherit system; inherit pkgs; }
