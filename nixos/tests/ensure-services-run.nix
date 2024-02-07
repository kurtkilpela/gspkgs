{
  pkgs ? import <nixpkgs> {},
  gspkgs ? import ./../../default.nix { inherit pkgs; },
  gemstone-package-name
}:

{
  "ensure-${gemstone-package-name}-stone-and-netldi-start" = pkgs.nixosTest {
    name = "ensure-${gemstone-package-name}-services-start";
    nodes.machine = {...}: {
      imports = [
        ./../default.nix
      ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      environment.systemPackages = [];

      services.gemstone = {
        enable = true;
        stones = {
          test-stone = {
            enable = true;
            package = gspkgs."${gemstone-package-name}";
          };
        };
        netldis = {
          test-netldi = {
            enable = true;
            package = gspkgs."${gemstone-package-name}";
          };
        };
      };

      system.stateVersion = "23.11";
    }; 
 
    testScript = {nodes, ...}: let
    in ''
      machine.start()
      machine.wait_for_unit("gemstone-stone-test-stone.service");
      machine.wait_for_unit("gemstone-netldi-test-netldi.service");
    '';
  };
}
