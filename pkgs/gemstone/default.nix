# This file is based on the definition of Ruby in nixpkgs.
# See: https://github.com/NixOS/nixpkgs/blob/06e3f80d461fb0326a1784cb86d7f6d0236401f2/pkgs/development/interpreters/ruby/default.nix
{ pkgs, lib, stdenv, fetchurl, unzip, autoPatchelfHook, gcc, ... } @ args:

let
  get-url = (version: system:
    {
      "x86_64-linux" = "https://downloads.gemtalksystems.com/pub/GemStone64/${version}/GemStone64Bit${version}-x86_64.Linux.zip";
      "aarch64-linux" = "https://downloads.gemtalksystems.com/pub/GemStone64/${version}/GemStone64Bit${version}-arm64.Linux.zip";
      "aarch64-darwin" = "https://downloads.gemtalksystems.com/pub/GemStone64/${version}/GemStone64Bit${version}-arm64.Darwin.dmg";
    }."${system}"
  );
  get-extracted-folder-name = (version: system:
    {
      "x86_64-linux" = "GemStone64Bit${version}-x86_64.Linux";
      "aarch64-linux" = "GemStone64Bit${version}-arm64.Linux";
      "aarch64-darwin" = "GemStone64Bit${version}-arm64.Darwin";
    }."${system}"
  );
  public-release = { version, platforms }: let
    self = lib.makeOverridable ({ pkgs, lib, stdenv, fetchurl, unzip, autoPatchelfHook, gcc, ... }:
      stdenv.mkDerivation rec {
        pname = "GemStone/S";
        inherit version;

        src = fetchurl {
          url = get-url version builtins.currentSystem;
          sha256 = platforms."${builtins.currentSystem}".sha256;
        };
        buildInputs = [ unzip gcc ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook pkgs.stdenv.cc.cc.lib pkgs.libcap pkgs.libpam-wrapper pkgs.xorg.libX11 pkgs.xorg.libXft pkgs.zlib pkgs.curl pkgs.libxcrypt-legacy pkgs.oracle-instantclient ];
        phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
        unpackPhase = lib.optionalString stdenv.isDarwin ''
          # Based on: https://github.com/NixOS/nixpkgs/blob/cec578e2b429bf59855063760d668cae355adb6d/pkgs/os-specific/darwin/aldente/default.nix#L23
          echo "File to unpack: $src"
          if ! [[ "$src" =~ \.dmg$ ]]; then return 1; fi
          mnt=$(mktemp -d -t ci-XXXXXXXXXX)

          function finish {
            echo "Detaching $mnt"
            /usr/bin/hdiutil detach $mnt -force
            rm -rf $mnt
          }
          trap finish EXIT

          echo "Attaching $mnt"
          /usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

          echo "Copying contents"
          cp -a $mnt/GemStone64Bit${version}-arm64.Darwin ./
      ''
      + lib.optionalString stdenv.isLinux ''
              unzip $src
      '';
      installPhase = ''
        mkdir -p $out
        cp -a ${get-extracted-folder-name version builtins.currentSystem}/* $out/
        chmod -R +w $out/doc
        mkdir -p $out/share/man
        mkdir -p $out/share/doc
        mv $out/doc/man* $out/share/man/
        mv $out/doc $out/share/doc/gemstone
      '';

        meta = with lib; {
          description = "GemStone/S";
          longDescription = ''
            GemStone Smalltalk distribution. Available as a binary package. Now available through nix.
          '';
          platforms = lib.attrNames platforms;
          homepage = "https://gemtalksystems.com/";
          license = licenses.unfreeRedistributable;
        };
    }) args; in self;
in
{
  gemstone_3_6_1 = public-release {
    version = "3.6.1";
    platforms."x86_64-linux".sha256 = "Y3Hkm4LXTDKLObLhfmblqb8iYYEYNgPGwrTtvfOWQZI=";
    platforms."aarch64-linux".sha256 = "OmFFUYGoC7ZElbGKdSI/q1FA/39DLN+geTJPz3NoTJU=";
  };
#  gemstone_3_6_1_1 = public-release {
#    version = "3.6.1.1";
#    platforms."x86_64-linux".sha256 = "DUxtp7V+QAJWwyAooBooG120o0+kv0/hvstK3BN4vXc=";
#  };
  gemstone_3_6_2 = public-release {
    version = "3.6.2";
    platforms."x86_64-linux".sha256 = "wCdi7UJYGam3ePP3yB5bnmd/4gXUK7q53g8QnJwManc=";
    platforms."aarch64-linux".sha256 = "Hexf5x4LSSzKDE9Yct75I49UNHmMKA544KXTULfNbN4=";
  };
  gemstone_3_6_3 = public-release {
    version = "3.6.3";
    platforms."x86_64-linux".sha256 = "uG6kE/BLInH4yyERVcvLKfTtqBs20QqpQlxhhVVRMSQ=";
    platforms."aarch64-linux".sha256 = "F44HRvjLp/JxEhYJhczdY7krpYN//ADuArVvwtaB/9M=";
  };
  gemstone_3_6_4 = public-release {
    version = "3.6.4";
    platforms."x86_64-linux".sha256 = "E12Lhuv9GSEK8GDJ3gjjxk9jeN8Ia0sxF+jtotMEBuk=";
    platforms."aarch64-linux".sha256 = "k/wAN/z2c6vhemC4nsRYJWpjVdOr83TKphLVjaFOLz0=";
  };
#  gemstone_3_6_4_1 = public-release {
#    version = "3.6.4.1";
#    platforms."x86_64-linux".sha256 = "ZWyM9XSx2F6P3JF4I0/e/yEsGDGzjU6RzZ4mSJkMAm8=";
#  };
  gemstone_3_6_5 = public-release {
    version = "3.6.5";
    platforms."x86_64-linux".sha256 = "n5XBNfXRb8LwSjGuWVxotQIx+IRySxQJoJtRhIreJ7I=";
    platforms."aarch64-linux".sha256 = "xSiLX/1Ihxxl3+GueMEZS/dpZYD/9G1puRu3DR9bLAw=";
  };
#  gemstone_3_6_5_1 = public-release {
#    version = "3.6.5.1";
#    platforms."x86_64-linux".sha256 = "L9uhU7ipqAaQhOcoUj934ZVgHNG8iwIp7h/id7BS4rc=";
#  };
  gemstone_3_6_6 = public-release {
    version = "3.6.6";
    platforms."x86_64-linux".sha256 = "dvSA7C0Yb9k1nNX0ZYa8N9wx211f5HgENM+2jAU4Aa4=";
    platforms."aarch64-linux".sha256 = "GtJa0J7amc7bA4z2/aNt1tg08gvYbVJWnkwx0Z6RUdY=";
  };
#  gemstone_3_6_6_1 = public-release {
#    version = "3.6.6.1";
#    platforms."x86_64-linux".sha256 = "px7v3YGIcNFO7XH4qxzQ8lQm5rBY00hiavJmx4KcOFY=";
#  };
#  gemstone_3_6_6_2 = public-release {
#    version = "3.6.6.2";
#    platforms."x86_64-linux".sha256 = "XWfVP3J5EYpqHjkbcxUgCoL4cRDOdpINHYlrqLMvOxw=";
#  };
  gemstone_3_6_8 = public-release {
    version = "3.6.8";
    platforms."x86_64-linux".sha256 = "4ttzRNjUvUhZ/2fuZrxJIi04l9xxPnzcRP+Z/UmNd5Q=";
    platforms."aarch64-linux".sha256 = "6Md/cjD77YIhUR8I1w6nvwGYava0fNyrLF5r2Xp9cl8=";
    platforms."aarch64-darwin".sha256 = "j5eJ+beG+fIPk9QF3Nij8Xbcht8lj7RLqmeRtYuhqKM=";
  };
  gemstone_3_7_0 = public-release {
    version = "3.7.0";
    platforms."x86_64-linux".sha256 = "FqCXRLLoTJ5rm8qMoEv4zPK/003rP1qOErYLQpRRNfY=";
    platforms."aarch64-linux".sha256 = "wYIL8RLYW8lyng5seFODUxOfQMqPeMDsvt+v/fe3Je0=";
    platforms."aarch64-darwin".sha256 = "yn0BeIMPSJL+//sjHucdVzEx+2Xgsodcq5T2u2tCsZE=";
  };
}


