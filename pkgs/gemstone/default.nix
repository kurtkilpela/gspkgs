# This file is based on the definition of Ruby in nixpkgs.
# See: https://github.com/NixOS/nixpkgs/blob/06e3f80d461fb0326a1784cb86d7f6d0236401f2/pkgs/development/interpreters/ruby/default.nix
{ lib, stdenv, fetchurl, unzip } @ args:

let
  get-url = (version: system:
    {
      "x86_64-linux" = "https://downloads.gemtalksystems.com/pub/GemStone64/${version}/GemStone64Bit${version}-x86_64.Linux.zip";
      "aarch64-darwin" = "https://downloads.gemtalksystems.com/pub/GemStone64/${version}/GemStone64Bit${version}-arm64.Darwin.dmg";
    }."${system}"
  );
  public-release = { version, platforms }: let
    self = lib.makeOverridable ({ lib, stdenv, fetchurl, unzip }:
      stdenv.mkDerivation rec {
        pname = "GemStone/S";
        inherit version;

        src = fetchurl {
          url = get-url version builtins.currentSystem;
          sha256 = platforms."${builtins.currentSystem}".sha256;
        };
        buildInputs = [ unzip ];
        phases = [ "unpackPhase" "installPhase" ];
        unpackPhase = ''
          # Based on: https://github.com/NixOS/nixpkgs/blob/cec578e2b429bf59855063760d668cae355adb6d/pkgs/os-specific/darwin/aldente/default.nix#L23
          unpackDmg() {
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

            echo "What's in the mount dir"?
            ls -la $mnt/

            echo "Copying contents"
            cp -a $mnt/GemStone64Bit${version}-arm64.Darwin ./
          }

          case ${builtins.currentSystem} in
            "x86_64-linux")
              unzip $src
              ;;
            "aarch64-darwin")
              unpackDmg
              ;;
            *)
              echo "Unkown system"
              exit 1
              ;;
          esac
        '';
        installPhase = ''
          mkdir -p $out
          case ${builtins.currentSystem} in
            "x86_64-linux")
              cp -a GemStone64Bit${version}-x86_64.Linux/* $out/
              ;;
            "aarch64-darwin")
              cp -a GemStone64Bit${version}-arm64.Darwin/* $out/
              ;;
            *)
              echo "Unkown system"
              exit 1
              ;;
          esac
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
  gemstone_3_6_0 = public-release {
    version = "3.6.0";
    platforms."x86_64-linux".sha256 = "/cu0h8bSksWHtZiIY+2dWL0Q41PLW/QI1QHY0Q7kKnY=";
  };
  gemstone_3_6_1 = public-release {
    version = "3.6.1";
    platforms."x86_64-linux".sha256 = "Y3Hkm4LXTDKLObLhfmblqb8iYYEYNgPGwrTtvfOWQZI=";
  };
  gemstone_3_6_1_1 = public-release {
    version = "3.6.1.1";
    platforms."x86_64-linux".sha256 = "DUxtp7V+QAJWwyAooBooG120o0+kv0/hvstK3BN4vXc=";
  };
  gemstone_3_6_2 = public-release {
    version = "3.6.2";
    platforms."x86_64-linux".sha256 = "wCdi7UJYGam3ePP3yB5bnmd/4gXUK7q53g8QnJwManc=";
  };
  gemstone_3_6_3 = public-release {
    version = "3.6.3";
    platforms."x86_64-linux".sha256 = "uG6kE/BLInH4yyERVcvLKfTtqBs20QqpQlxhhVVRMSQ=";
  };
  gemstone_3_6_4 = public-release {
    version = "3.6.4";
    platforms."x86_64-linux".sha256 = "E12Lhuv9GSEK8GDJ3gjjxk9jeN8Ia0sxF+jtotMEBuk=";
  };
  gemstone_3_6_4_1 = public-release {
    version = "3.6.4.1";
    platforms."x86_64-linux".sha256 = "ZWyM9XSx2F6P3JF4I0/e/yEsGDGzjU6RzZ4mSJkMAm8=";
  };
  gemstone_3_6_5 = public-release {
    version = "3.6.5";
    platforms."x86_64-linux".sha256 = "n5XBNfXRb8LwSjGuWVxotQIx+IRySxQJoJtRhIreJ7I=";
  };
  gemstone_3_6_5_1 = public-release {
    version = "3.6.5.1";
    platforms."x86_64-linux".sha256 = "L9uhU7ipqAaQhOcoUj934ZVgHNG8iwIp7h/id7BS4rc=";
  };
  gemstone_3_6_6 = public-release {
    version = "3.6.6";
    platforms."x86_64-linux".sha256 = "dvSA7C0Yb9k1nNX0ZYa8N9wx211f5HgENM+2jAU4Aa4=";
  };
  gemstone_3_6_6_1 = public-release {
    version = "3.6.6.1";
    platforms."x86_64-linux".sha256 = "px7v3YGIcNFO7XH4qxzQ8lQm5rBY00hiavJmx4KcOFY=";
  };
  gemstone_3_6_6_2 = public-release {
    version = "3.6.6.2";
    platforms."x86_64-linux".sha256 = "XWfVP3J5EYpqHjkbcxUgCoL4cRDOdpINHYlrqLMvOxw=";
  };
  gemstone_3_7_0 = public-release {
    version = "3.7.0";
    platforms."x86_64-linux".sha256 = "FqCXRLLoTJ5rm8qMoEv4zPK/003rP1qOErYLQpRRNfY=";
    platforms."aarch64-darwin".sha256 = "yn0BeIMPSJL+//sjHucdVzEx+2Xgsodcq5T2u2tCsZE=";
  };
}


