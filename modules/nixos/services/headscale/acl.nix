{
  lib,
  self,
  config,
  ...
}: let
  inherit (self.lib) mkOpt mkOpt';
  inherit (lib.types) str enum listOf attrsOf nullOr;

  # see: https://tailscale.com/kb/1337/policy-syntax#acls
  ruleType = lib.types.submodule {
    options = {
      action = mkOpt (enum ["accept"]) "accept" "The action";
      src = mkOpt' (listOf str) "The sources this rule applies to";
      proto = mkOpt (nullOr str) null "The protocol this rule applies to";
      dst = mkOpt' (listOf str) "The destinations this rule applies to";
    };
  };

  cfg = config.services.headscale.settings.declarative;
in {
  options.services.headscale.settings.declarative = {
    autoApprovers = {
      exitNode = mkOpt (listOf str) [] "Users which can advertise exit nodes without approval";
      routes = mkOpt (attrsOf (listOf str)) {} "Routes which specified users can advertise without approval";
    };
    acls = mkOpt (listOf ruleType) [] "Headscale ACLs";
    tagOwners = mkOpt (attrsOf (listOf str)) {} "List of users allowed to assign specific tags";
    groups = mkOpt (attrsOf (listOf str)) {} "Groups of users, devices and subnets";
    hosts = mkOpt (attrsOf str) {} "Aliases for devices and subnets";
  };

  config = lib.mkIf config.garden.services.headscale.enable {
    services.headscale.settings.policy = {
      mode = lib.mkForce "file";

      path = lib.toFile "policy.hujson" (
        builtins.toJSON {
          inherit (cfg) hosts autoApprovers;
          acls = builtins.map (r:
            if r.proto == null
            then builtins.removeAttrs r ["proto"]
            else r)
          cfg.acls;
          tagOwners = lib.mapAttrs' (n: v: lib.nameValuePair "tag:${n}" v) cfg.tagOwners;
          groups = lib.mapAttrs' (n: v: lib.nameValuePair "group:${n}" v) cfg.groups;
        }
      );
    };
  };
}
