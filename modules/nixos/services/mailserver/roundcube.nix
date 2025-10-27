{
  pkgs,
  self,
  lib,
  config,
  ...
}: let
  cfg = config.garden.services.roundcube;
in {
  options.garden.services.roundcube = self.lib.mkServiceOpt "roundcube" {
    domain = "webmail.${config.garden.domain}";
    depends.local = ["postgresql" "nginx" "mailserver"];

    proxy = {
      enable = false;
      visibility = "public";
    };

    dash = {
      enable = true;
      icon = "sh:roundcube-light";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      roundcube = {
        enable = true;

        package = pkgs.roundcube.withPlugins (
          plugins: with plugins; [persistent_login]
        );
        plugins = [
          "persistent_login"
        ];

        dicts = [pkgs.aspellDicts.en];
        maxAttachmentSize = 50;

        hostName = cfg.domain;
        extraConfig = ''
          $config['smtp_host'] = "ssl://${config.mailserver.fqdn}";
          $config['smtp_user'] = "%u";
          $config['smtp_pass'] = "%p";
        '';
      };

      nginx.virtualHosts."${cfg.domain}" = {
        enableACME = lib.mkForce false;
        locations."/".extraConfig = lib.mkForce "";
      };

      postgresql = {
        ensureDatabases = ["roundcube"];
        ensureUsers = [
          {
            name = "roundcube";
            ensureDBOwnership = true;
          }
        ];
      };
    };
  };
}
