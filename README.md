## GemStone Nix Repository

This repository is an unofficial GemStone/S nix repository.

## Current Plans

- GemStone/S NixOS module (WIP)
- Flake support

## Adding Channel

```
nix-channel --add https://github.com/kurtkilpela/gspkgs/archive/refs/heads/main.tar.gz gspkgs
nix-channel --update
```

## Opening a Shell

```
nix-shell -p '(import <gspkgs>{}).gemstone'
```

## Adding New Versions

Add entry for new version w/ fakeSah256 hash.

```
  gemstone_3_x_y = public-release {
    version = "3.x.y";
    platforms."x86_64-linux".sha256 = lib.fakeSha256;
    platforms."aarch64-darwin".sha256 = lib.fakeSah256;
  };
```

Inherit new version in default.nix and update gemstone_3_x, if appropriate.

Run build on each platform and update hash based on hash provided in error message.

```
nix-build -A gemstone_3_7_9
```
