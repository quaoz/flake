{
  lib,
  self,
  config,
  ...
}: let
  cfg = config.garden.services.blocky;
  inherit (config.garden.services) unbound;
in {
  options.garden.services.blocky = self.lib.mkServiceOpt "blocky" {
    visibility = "internal";
    dependsLocal = ["unbound"];
    domain = "${config.networking.hostName}.${config.garden.magic.internal.domain}";
    proxy = false;
    port = 53;
    host = "127.0.0.1";
  };

  # if enabled blocky will replace the default dns
  config = lib.mkIf cfg.enable {
    # needed for tailscale magic dns to work
    environment.etc."resolv.conf".text = ''
      search ${config.garden.magic.internal.domain}
      nameserver 127.0.0.1
      nameserver 100.100.100.100
      options edns0 trust-ad
    '';

    # wait for unbound to start
    systemd.services.blocky = {
      after = ["unbound.service"];
      wants = ["unbound.service"];
    };

    # disable systemd-resolved
    networking.networkmanager.dns = lib.mkForce "none";
    services = {
      resolved.enable = lib.mkForce false;

      blocky = {
        enable = true;

        settings = {
          ports.dns = cfg.port;

          log = {
            level = "warn";
            privacy = lib.mkDefault true;
          };

          # use unbound as the upstream dns
          bootstrapDns.upstream = "${unbound.host}:${unbound.port}";
          upstreams.groups.default = ["${unbound.host}:${unbound.port}"];

          # enable prefetching
          caching.prefetching = true;

          blocking = {
            loading = {
              # make startup more forgiving to allow unbound to start
              downloads = lib.mkIf unbound.enable {
                attempts = 10;
                cooldown = "2s";
              };

              # start serving mmediately and initialize in the background
              strategy = "fast";
            };

            clientGroupsBlock = {
              default = [
                "multi"
                "ads"
                "tracking"
                "malicious"
              ];
            };

            # mainly sourced from https://firebog.net/
            denylists = {
              multi = [
                "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
                "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
                "https://v.firebog.net/hosts/static/w3kbl.txt"
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              ];

              ads = [
                "https://adaway.org/hosts.txt"
                "https://v.firebog.net/hosts/AdguardDNS.txt"
                "https://v.firebog.net/hosts/Admiral.txt"
                "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
                "https://v.firebog.net/hosts/Easylist.txt"
                "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
                "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
                "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
              ];

              tracking = [
                "https://v.firebog.net/hosts/Easyprivacy.txt"
                "https://v.firebog.net/hosts/Prigent-Ads.txt"
                "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
                "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
                "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
              ];

              malicious = [
                "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
                "https://v.firebog.net/hosts/Prigent-Crypto.txt"
                "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
                "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
                "https://phishing.army/download/phishing_army_blocklist_extended.txt"
                "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
                "https://v.firebog.net/hosts/RPiList-Malware.txt"
                "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
                "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
                "https://urlhaus.abuse.ch/downloads/hostfile/"
                "https://lists.cyberhost.uk/malware.txt"
              ];
            };
          };
        };
      };
    };
  };
}
