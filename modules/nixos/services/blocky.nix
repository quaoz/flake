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
    port = 53;
    host = "127.0.0.1";
    depends.local = ["unbound"];

    proxy = {
      proxy = false;
      visibility = "internal";
    };
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

        # https://0xerr0r.github.io/blocky/latest/configuration/
        settings = {
          ports.dns = cfg.port;

          log = {
            level = "warn";
            privacy = lib.mkDefault true;
          };

          # use unbound as the upstream dns
          bootstrapDns.upstream = "${unbound.host}:${builtins.toString unbound.port}";
          upstreams.groups.default = ["${unbound.host}:${builtins.toString unbound.port}"];

          conditional.mapping = {
            "${config.garden.magic.internal.domain}" = "100.100.100.100";
          };

          clientLookup = {
            upstream = "100.100.100.100";
            clients =
              self.lib.hosts self {}
              |> lib.mapAttrs' (hn: hc: let
                inherit (hc.config.garden.networking.addresses) internal;
              in {
                name = "${hn}.${config.garden.magic.internal.domain}";
                value = builtins.concatLists [
                  (lib.optionals internal.ipv4.enable [internal.ipv4.address])
                  (lib.optionals internal.ipv6.enable [internal.ipv6.address])
                  (lib.optionals (hn == config.networking.hostName) ["::1" "127.0.0.1"])
                ];
              });
          };

          # enable prefetching
          caching = {
            prefetching = true;
            cacheTimeNegative = "60s";
          };

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

            clientGroupsBlock =
              {
                default = [
                  "base"
                  "normal"
                ];
              }
              // (self.lib.hosts self {includeDarwin = true;}
                |> lib.mapAttrs' (
                  _hn: hc: {
                    name = "${hc.config.networking.hostName}*";
                    value = ["base" "normal" "big"];
                  }
                ));

            # sources:
            #   - https://github.com/StevenBlack/hosts
            #   - https://github.com/hagezi/dns-blocklists
            #   - https://oisd.nl
            #   - https://firebog.net/
            #   - https://github.com/badmojr/1Hosts
            #   - https://github.com/PrimePoobah/Pi-hole-Blocklist-Catalog
            #
            # while IFS= read -r url; do echo "$url"; curl -fsSL "$url" | rg '<domain>'; done < <(nix eval --raw --impure --expr '(builtins.getFlake "'$PWD'").nixosConfigurations.ganymede.config.services.blocky.settings.blocking.denylists |> builtins.attrValues |> builtins.concatLists |> builtins.concatStringsSep "\n"')
            denylists = {
              base = [
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                "https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/wildcards.txt"
                "https://urlhaus.abuse.ch/downloads/hostfile/"
                "https://threatfox.abuse.ch/downloads/hostfile/"
                "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/master/phishing.txt"
                "https://adaway.org/hosts.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/master/crypto.txt"
                "https://v.firebog.net/hosts/Prigent-Crypto.txt"
              ];

              small = [
                "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/multi.txt"
                "https://small.oisd.nl/domainswild"
              ];

              normal = [
                "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/pro.txt"
                "https://big.oisd.nl/domainswild"
                "https://phishing.army/download/phishing_army_blocklist_extended.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/master/ransomware.txt"
              ];

              big = [
                "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/tif.txt"
                "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/fake.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/master/scam.txt"
                "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
                "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/easylist"
                "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Win10Telemetry"
                "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
                "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
                "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
              ];
            };
          };
        };
      };
    };
  };
}
