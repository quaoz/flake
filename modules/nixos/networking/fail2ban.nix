{
  config,
  self,
  ...
}: {
  garden.persist.dirs = ["/var/lib/fail2ban"];

  environment.etc = {
    "fail2ban/filter.d/nginx-url-probe.local".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      failregex = ^<HOST>.*(GET /(wp-|admin|boaform|phpmyadmin|\.env|\.git)|\.(dll|so|cfm|asp)|(\?|&)(=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000|=PHPE9568F36-D428-11d2-A769-00AA001ACF42|=PHPE9568F35-D428-11d2-A769-00AA001ACF42|=PHPE9568F34-D428-11d2-A769-00AA001ACF42)|\\x[0-9a-zA-Z]{2}) [3-5]
      ignoreregex =
    '';

    "fail2ban/filter.d/vaultwarden-web.local".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      failregex = ^.*?Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
      ignoreregex =
    '';

    "fail2ban/filter.d/vaultwarden-admin.local".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      failregex = ^.*Invalid admin token\. IP: <ADDR>.*$
      ignoreregex =
    '';
  };

  services.fail2ban = {
    enable = true;
    bantime = "1h";
    maxretry = 2;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
    ];

    bantime-increment = {
      enable = true;

      # double ban until 256 hours
      multipliers =
        builtins.genList (a: a) 8
        |> builtins.map (a: builtins.toString (self.lib.pow 2 a))
        |> builtins.concatStringsSep " ";
      maxtime = "256h";

      # check ip across all jails
      overalljails = true;

      # add random value to bantime
      rndtime = "1h";
    };

    jails = {
      sshd.settings = {
        enabled = config.services.openssh.enable;
        mode = "aggressive";
        maxretry = 1;
      };

      # vaultwarden
      vaultwarden-web.settings = {
        enabled = config.garden.services.vaultwarden.enable;
        filter = "vaultwarden-web";
        journalmatch = "_SYSTEMD_UNIT=vaultwarden.service";
        backend = "%(syslog_backend)s";
        port = "80,443,${builtins.toString config.garden.services.vaultwarden.port}";
        findtime = "6h";
      };

      vaultwarden-admin.settings = {
        enabled = config.garden.services.vaultwarden.enable;
        filter = "vaultwarden-admin";
        journalmatch = "_SYSTEMD_UNIT=vaultwarden.service";
        backend = "%(syslog_backend)s";
        port = "80,443,${builtins.toString config.garden.services.vaultwarden.port}";
        findtime = "6h";
      };

      # nginx
      nginx-url-probe.settings = {
        enabled = config.services.nginx.enable;
        filter = "nginx-url-probe";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        findtime = "1h";
      };

      nginx-bad-request.settings = {
        enabled = config.services.nginx.enable;
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        findtime = "1h";
      };

      nginx-botsearch.settings = {
        enabled = config.services.nginx.enable;
        logpath = "/var/log/nginx/error.log";
        backend = "auto";
        findtime = "1h";
      };

      nginx-forbidden.settings = {
        enabled = config.services.nginx.enable;
        logpath = "/var/log/nginx/error.log";
        backend = "auto";
        findtime = "1h";
      };

      php-url-fopen.settings = {
        enabled = config.services.nginx.enable;
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 1;
      };

      # mail
      postfix.settings = {
        enabled = config.services.postfix.enable;
        mode = "aggressive";
        findtime = "6h";
      };

      postfix-sasl.settings = {
        enabled = config.services.postfix.enable;
        findtime = "6h";
      };

      dovecot.settings = {
        enabled = config.services.dovecot2.enable;
        mode = "aggressive";
        journalmatch = "_SYSTEMD_UNIT=dovecot.service";
        backend = "%(syslog_backend)s";
        findtime = "6h";
      };

      roundcube-auth.settings = {
        enabled = config.services.roundcube.enable;
        backend = "%(syslog_backend)s";
        findtime = "6h";
      };
    };
  };
}
