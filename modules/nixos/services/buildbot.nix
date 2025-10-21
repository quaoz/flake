{
  inputs',
  inputs,
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.age) secrets;
  cfg = config.garden.services.buildbot;
in {
  options.garden.services.buildbot = self.lib.mkServiceOpt "buildbot" {
    visibility = "public";
    dependsLocal = ["postgresql" "nginx"];
    dependsAnywhere = ["attic"];
    proxy = false;
    port = 3006;
    host = "0.0.0.0";
    domain = "ci.${config.garden.domain}";
  };

  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  config = lib.mkIf cfg.enable {
    garden.secrets = {
      other = [
        {
          path = "services/buildbot/github-oauth-secret.age";
          user = "buildbot";
          group = "buildbot";
        }
        {
          path = "services/buildbot/github-app-secret.age";
          user = "buildbot";
          group = "buildbot";
        }
      ];

      normal = {
        buildbot-github-webhook-secret = {
          owner = "buildbot";
          group = "buildbot";
          generator.script = "alnum";
        };

        buildbot-worker = {
          owner = "buildbot-worker";
          group = "buildbot-worker";
          generator.script = "alnum";
        };

        buildbot-workers-file = {
          owner = "buildbot";
          group = "buildbot";

          generator = {
            dependencies.worker = secrets.buildbot-worker;
            script = {
              deps,
              decrypt,
              ...
            }: ''
              echo "[{\"name\":\"${config.networking.hostName}\", \"pass\":\"$(${decrypt} ${lib.escapeShellArg deps.worker.file})\", \"cores\":4}]"
            '';
          };
        };
      };
    };

    systemd.services.attic-watch-store = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      environment.HOME = "/var/lib/attic-watch-store";
      serviceConfig = {
        DynamicUser = true;
        MemoryMax = "10%";
        LoadCredential = "attic-auth-token:${secrets.attic-normal-token.path}";
        StateDirectory = "attic-watch-store";
        Restart = "always";
      };

      path = [pkgs.attic-client config.nix.package];
      script = ''
        set -euo pipefail
        ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/attic-auth-token)
        attic login attic https://${config.garden.services.attic.domain} $ATTIC_TOKEN
        attic use prod
        exec attic watch-store attic:prod
      '';
    };

    services = {
      postgresql = {
        ensureDatabases = ["buildbot"];
        ensureUsers = [
          {
            name = "buildbot";
            ensureDBOwnership = true;
          }
        ];
      };

      buildbot-nix = {
        worker = {
          enable = true;
          name = config.networking.hostName;
          workerPasswordFile = secrets.buildbot-worker.path;

          # the lix overlay replaces nix-eval-jobs with a version incompatible with buildbot
          nixEvalJobs.package = inputs'.nixpkgs.legacyPackages.nix-eval-jobs;
        };

        master = {
          enable = true;

          useHTTPS = true;
          inherit (cfg) domain;

          dbUrl = "postgresql://buildbot?host=/run/postgresql";

          workersFile = secrets.buildbot-workers-file.path;
          buildSystems =
            builtins.foldl'
            (a: b: a ++ b.systems ++ [b.system])
            [pkgs.stdenv.hostPlatform.system]
            config.nix.buildMachines
            |> lib.unique;

          branches = {
            all = {
              matchGlob = "*";
              registerGCRoots = false;
            };
          };

          admins = ["quaoz"];
          authBackend = "github";
          github = {
            enable = true;
            topic = "buildbot";

            appId = 2135760;
            appSecretKeyFile = secrets.buildbot-github-app-secret.path;

            webhookSecretFile = secrets.buildbot-github-webhook-secret.path;

            oauthId = "Iv23lizBcVvBRyk33RxV";
            oauthSecretFile = secrets.buildbot-github-oauth-secret.path;
          };
        };
      };
    };
  };
}
