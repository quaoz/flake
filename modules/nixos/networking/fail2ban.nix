{
  garden.persist.dirs = ["/var/lib/fail2ban"];

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
    ];

    bantime-increment = {
      enable = true;

      # check ip across all jails
      overalljails = true;

      # add random value to bantime
      rndtime = "16m";

      # max out at 1 week
      maxtime = "168h";
    };

    jails = {
      sshd.settings.mode = "aggressive";
    };
  };
}
