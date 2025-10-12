{
  config,
  self,
  lib,
  ...
}: let
  domainType = lib.types.submodule ({config, ...}: let
    domain = config._module.args.name;
  in {
    options = {
      registrar = self.lib.mkOpt' lib.types.str "The registrar for ${domain}";
      dnsProvider = self.lib.mkOpt' lib.types.str "The dns provider for ${domain}";
      extraRecords = self.lib.mkOpt (lib.types.listOf lib.types.attrs) [] "Extra records for ${domain}";
    };
  });

  cfg = config.garden.magic.public;
in {
  options.garden.magic.public = {
    enable = lib.mkEnableOption "automatic proxying for public services";
    domains = self.lib.mkOpt (lib.types.attrsOf domainType) {} "The domains to be proxied";
  };

  config = lib.mkIf cfg.enable {
    # check only one host is proxying each domain
    assertions = let
      overlap =
        self.lib.hostsWhere self (hn: hc: hn != config.networking.hostName && hc.config.garden.magic.public.enable) {}
        |> builtins.attrValues
        |> builtins.map (host: builtins.attrNames host.config.garden.magic.public.domains)
        |> lib.flatten
        |> builtins.filter (domain: builtins.hasAttr domain cfg.domains);
    in [
      {
        assertion = config.garden.networking.addresses.public.ipv4.enable || config.garden.networking.addresses.public.ipv6.enable;
        message = ''
          No public ip addresses have been enabled. You should configure
          `garden.networking.addresses.public`.
        '';
      }
      {
        assertion = config.garden.services.nginx.enable;
        message = "Nginx must be enabled on `${config.networking.hostName}` for public proxying to work.";
      }

      {
        assertion = builtins.length overlap == 0;
        message = ''
          Other hosts are configured as proxies for:
            - `${builtins.concatStringsSep "\n  -" overlap}`
        '';
      }
    ];
  };
}
