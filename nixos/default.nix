{ config, lib, pkgs, utils, ... }:

with lib;

let

  cfg = config.services.gemstone;
  systemConfig = (extentDir: tranLogDir: pkgs.writeText "system.conf" ''
    DBF_EXTENT_NAMES = ${extentDir}/extent0.dbf;
    STN_TRAN_LOG_DIRECTORIES = ${tranLogDir}/;
    STN_TRAN_FULL_LOGGING = TRUE;
    STN_TRAN_LOG_SIZES = 100 MB;
    GEM_TEMPOBJ_CACHE_SIZE = 5 GB;
  '');
  stoneRuntimeDirectory = (stoneName: "\${RUNTIME_DIRECTORY}");
  systemConfigRuntimeLocation = (stoneName: "${stoneRuntimeDirectory stoneName}/system.conf");

  stoneOpts = { name, ... }:
  let
    stoneCfg = cfg.stones.${name};
  in
  {
    options = {
      enable = mkEnableOption (mdDoc "GemStone Service - ${name}");
      initialize = mkOption {
        type = types.bool;
        default = true;
        description = mkDoc "Initialize a Stone if it doesn't already exist.";
      };
      serviceName = mkOption {
        default = "gemstone-stone-${name}";
        type = types.str;
        description = lib.mdDoc "Specify the name of the SystemD service.";
      };
      package = mkOption {
        type = types.package;
        default = (pkgs.callPackage ../. {}).gemstone;
        defaultText = "gspkgs.gemstone";
        description = mkDoc "The GemStone package to use for this stone.";
      };
      stateDir = mkOption {
        default = "${cfg.baseDir}/stones/${name}";
        type = types.str;
        description = lib.mdDoc "GemStone data directory for this stone.";
      };
      extentDir = mkOption {
        default = "${stoneCfg.stateDir}/extents";
        type = types.str;
        description = lib.mdDoc "Stone extent directory";
      };
      tranLogDir = mkOption {
        default = "${stoneCfg.stateDir}/tranLogs";
        type = types.str;
        description = lib.mdDoc "Stone extent directory";
      };
      logDir = mkOption {
        default = "${stoneCfg.stateDir}/logs";
        type = types.str;
        description = lib.mdDoc "Stone log directory";
      };
      defaultExtent = mkOption {
        default = "extent0.dbf";
        type = types.enum [ "extent0.dbf" "extent0.seaside.dbf" ];
        description = lib.mdDoc "Specify the extent to be used when setting up a fresh environment.";
      };
      environment = mkOption {
        type = with types; attrsOf str;
        default = {
          GEMSTONE = "${stoneCfg.package}";
          GEMSTONE_LOG = "${stoneCfg.logDir}/${name}.log";
        };
        example = { GEMSTONE_GLOBAL_DIR = "/opt/gemstone"; };
        description = lib.mdDoc ''
          Set the environment variables for this stone. You must set GEMSTONE if you change the value from the default.

          This option overrides the default environment variables. Use `extraEnvironment` if you want to override individual options or if you want to add additional variables.
        '';
      };
      extraEnvironment = mkOption {
        type = with types; attrsOf str;
        default = {};
        example = { GEMSTONE_GLOBAL_DIR = "/opt/gemstone"; };
        description = lib.mdDoc ''
          Add additional environment variables for this stone. You can use this value to avoid having to provide the default values. Values provided here override values set in `environment`.
        '';
      };
    };
  };

  netldiOpts = { name, ... }:
  let
    netldiCfg = cfg.netldis.${name};
  in
  {
    options = {
      enable = mkEnableOption (mdDoc "GemStone NetLDI - ${name}");
      initialize = mkOption {
        type = types.bool;
        default = true;
        description = mkDoc "Initialize a NetLDI if it doesn't already exist.";
      };
      serviceName = mkOption {
        default = "gemstone-netldi-${name}";
        type = types.str;
        description = lib.mdDoc "Specify the name of the SystemD service.";
      };
      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        defaultText = "null";
        description = mkDoc "Specify the port used by this NetLDI.";
      };
      package = mkOption {
        type = types.package;
        default = (pkgs.callPackage ../. {}).gemstone;
        defaultText = "gspkgs.gemstone";
        description = mkDoc "The GemStone package to use for this NetLDI.";
      };
      stateDir = mkOption {
        default = "${cfg.baseDir}/netldis/${name}";
        type = types.str;
        description = lib.mdDoc "GemStone data directory for this NetLDI.";
      };
      logDir = mkOption {
        default = "${netldiCfg.stateDir}/logs";
        type = types.str;
        description = lib.mdDoc "NetLDI log directory";
      };
      environment = mkOption {
        type = with types; attrsOf str;
        default = {
          GEMSTONE = "${netldiCfg.package}";
        };
        example = { GEMSTONE_GLOBAL_DIR = "/opt/gemstone"; };
        description = lib.mdDoc ''
          Set the environment variables for this NetLDI. You must set GEMSTONE if you change the value from the default.

          This option overrides the default environment variables. Use `extraEnvironment` if you want to override individual options or if you want to add additional variables.
        '';
      };
      extraEnvironment = mkOption {
        type = with types; attrsOf str;
        default = {};
        example = { ROWAN_PROJECTS_HOME = "/var/lib/gemstone/rowan"; };
        description = lib.mdDoc ''
          Add additional environment variables for this NetLDI. You can use this value to avoid having to provide the default values. Values provided here override values set in `environment`.
        '';
      };
      };
    };

  optionalAttrSet = condition: optionalResult: if condition then optionalResult else {};

  ensureDirectory = (directory: ''
    if [ ! -d "${directory}" ]; then
      mkdir -p "${directory}"
    fi
  '');

  generateNetLDIService = (name: netldiCfg:
    optionalAttrSet netldiCfg.enable {
      "${netldiCfg.serviceName}" = {
        description = "GemStone/S";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ netldiCfg.package ];
        preStart = lib.optionalString netldiCfg.initialize ''
          ${ensureDirectory "${netldiCfg.stateDir}"}
          ${ensureDirectory "${netldiCfg.logDir}"}
        '';
        environment = netldiCfg.environment // netldiCfg.extraEnvironment;
        serviceConfig = {
          Type = "forking";
          User = "gemstone";
          Group = "gemstone";
          WorkingDirectory = "~"; # Was netldiCfg.stateDir. This directory has to exist but I don't see a way of having Systemd create it to start.
          Restart = "always";
          ExecStart = "${netldiCfg.package}/bin/startnetldi ${name} -ga \"gemstone\" ${lib.optionalString (netldiCfg.port != null) "-P ${toString netldiCfg.port}"} -D ${netldiCfg.logDir}";
          ExecStop = "${netldiCfg.package}/bin/stopnetldi ${name}";
          RuntimeDirectory = "${netldiCfg.serviceName}";
          RuntimeDirectoryMode = "0755";
        };
      };
    }
  );

  generateStoneService = (name: cfg:
    optionalAttrSet cfg.enable {
      "${cfg.serviceName}" = {
        description = "GemStone/S";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ cfg.package ];
        preStart = lib.optionalString cfg.initialize ''
          ${ensureDirectory "${cfg.stateDir}"}
          ${ensureDirectory "${cfg.extentDir}"}
          ${ensureDirectory "${cfg.tranLogDir}"}
          ${ensureDirectory "${cfg.logDir}"}
          if [ ! -f "${cfg.extentDir}/extent0.dbf" ]; then
            cp "${cfg.package}/bin/${cfg.defaultExtent}" "${cfg.extentDir}/extent0.dbf"
            chmod 600 "${cfg.extentDir}/extent0.dbf"
          fi
        '' + ''
          cp ${systemConfig cfg.extentDir cfg.tranLogDir} ${systemConfigRuntimeLocation name}
          chmod +w ${systemConfigRuntimeLocation name}
        '';
        environment = cfg.environment // cfg.extraEnvironment;
        serviceConfig = {
          Type = "forking";
          User = "gemstone";
          Group = "gemstone";
          WorkingDirectory = "~"; # Was cfg.stateDir. This directory has to exist but I don't see a way of having Systemd create it to start.
          Restart = "always";
          ExecStart = "${cfg.package}/bin/startstone -z ${systemConfigRuntimeLocation name} ${name}";
          ExecStop = "${cfg.package}/bin/stopstone ${name}";
          RuntimeDirectory = "${cfg.serviceName}";
          RuntimeDirectoryMode = "0755";
        };
      };
    }
  );

in
{
  options = {
    services.gemstone = {
      enable = mkEnableOption (mdDoc "Enable GemStone");
      baseDir = mkOption {
        default = "/var/lib/gemstone";
        type = types.str;
        description = lib.mdDoc "Default base directory to use for GemStone Services. Also serves at the home directory for the `gemstone` user.";
      };
      stones = mkOption {
        default = {};
        example = {};
        description = lib.mdDoc ''
          Stone definitions.
        '';
        type = with types; attrsOf (submodule stoneOpts);
      };
      netldis = mkOption {
        default = {};
        example = {};
        description = lib.mdDoc ''
          NetLDI definitions.
        '';
        type = with types; attrsOf (submodule netldiOpts);
      };
    };
  };

  config = mkIf (cfg.enable) {
    #environment.systemPackages = [ cfg.package ];

    system.activationScripts.opt-gemstone = ''
      mkdir -p /opt
      mkdir -p /opt/gemstone
      mkdir -p /opt/gemstone/log
      mkdir -p /opt/gemstone/locks
      chown -R gemstone:gemstone /opt/gemstone
    '';

    users.users = {
      gemstone = {
        description = "GemStone Service";
        home = cfg.baseDir;
        useDefaultShell = true;
        group = "gemstone";
        createHome = true;
        isSystemUser = true;
      };
    };

    users.groups = {
      gemstone = {};
    };


    systemd.services = lib.fold (name: acc: acc // (generateStoneService name (cfg.stones.${name}))) {} (attrNames cfg.stones)
      // lib.fold (name: acc: acc // (generateNetLDIService name (cfg.netldis.${name}))) {} (attrNames cfg.netldis);

  };
}
