{
  lib,
  pkgs,
  self,
  inputs,
  inputs',
  osConfig,
  ...
}: let
  package =
    self.lib.ldTernary pkgs
    inputs'.firefox-nightly.packages.firefox-nightly-bin
    (
      pkgs.wrapFirefox ((inputs.firefox-darwin.overlay {} pkgs).firefox-nightly-bin.overrideAttrs {
        applicationName = "Firefox Nightly";

        # WATCH: https://github.com/bandithedoge/nixpkgs-firefox-darwin/issues/14
        nativeBuildInputs = [pkgs.makeBinaryWrapper];
        postInstall = ''
          wrapProgram $out/Applications/Firefox\ Nightly.app/Contents/MacOS/firefox --set MOZ_LEGACY_PROFILES 1
        '';
      }) {}
    );
in {
  programs.firefox = lib.mkIf osConfig.garden.profiles.desktop.enable {
    enable = true;
    inherit package;

    profiles."default" = {
      id = 0;
      isDefault = true;

      settings = {
        "extensions.autoDisableScopes" = 0;
      };

      # use betterfox user.js
      extraConfig = builtins.readFile "${pkgs.betterfox}/user.js" + builtins.readFile ./overrides.js;

      # TODO: i don't actually want a lot of these
      extensions.packages = with inputs'.firefox-addons.packages; [
        # keep-sorted start
        auto-tab-discard
        bitwarden
        blocktube
        buster-captcha-solver
        control-panel-for-twitter
        cookies-txt
        darkreader
        dearrow
        don-t-fuck-with-paste
        header-editor
        indie-wiki-buddy
        justdeleteme
        lovely-forks
        search-by-image
        sponsorblock
        stylus
        terms-of-service-didnt-read
        translate-web-pages
        ublacklist
        ublock-origin
        unpaywall
        user-agent-string-switcher
        userchrome-toggle-extended
        violentmonkey
        wayback-machine
        web-scrobbler
        zotero-connector
        # keep-sorted end
      ];

      search = let
        mkSearchFull = {
          alias,
          domain,
          searchPath ? "/search",
          searchParam ? "q",
          extraParams ? [],
        }: {
          icon = "https://" + domain + "/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;

          definedAliases = ["@${alias}"];
          urls = [
            {
              template = "https://" + domain + searchPath;
              params =
                [
                  {
                    name = searchParam;
                    value = "{searchTerms}";
                  }
                ]
                ++ extraParams;
            }
          ];
        };

        mkSearch' = alias: domain: extra:
          mkSearchFull ({
              inherit alias domain;
            }
            // extra);

        mkSearch = alias: domain: mkSearch' alias domain {};
      in {
        default = "ddg";
        force = true;

        # TODO: i also don't really want some of these
        engines = {
          "bing".metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          "ebay".metaData.hidden = true;

          "mynixos" = mkSearch "mynix" "mynixos.com";
          "github" = mkSearch "gh" "github.com";
          "mdn" = mkSearch "mdn" "developer.mozilla.org";
          "lastfm" = mkSearch "lastfm" "last.fm";
          "effectindex" = mkSearch "effect" "effectindex.com";
          "annasarchive" = mkSearch "aa" "annas-archive.org";

          "youtube" = mkSearch' "yt" "youtube.com" {searchPath = "/results";};
          "googlescholar" = mkSearch' "scholar" "scholar.google.com" {searchPath = "/scholar";};

          "rym" = mkSearch' "rym" "rateyourmusic.com" {searchParam = "searchterm";};
          "thedrugclassroom" = mkSearch' "tdc" "thedrugclassroom.com" {searchParam = "s";};

          "e621" = mkSearch' "e621" "e621.net" {
            searchPath = "/posts";
            searchParam = "tags";
          };

          "psychonaut" = mkSearch' "psy" "psychonautwiki.org" {
            searchPath = "/w/index.php";
            searchParam = "search";
          };

          "tripsit" = mkSearch' "tripsit" "wiki.tripsit.me" {
            searchPath = "/index.php";
            searchParam = "search";
          };

          "noogle" = mkSearch' "noogle" "noogle.dev" {
            searchPath = "/q";
            searchParam = "term";
          };

          "nüschtos" = mkSearch' "nüschtos" "search.xn--nschtos-n2a.de" {
            searchPath = "/";
            searchParam = "query";
          };

          "searchix" = mkSearch' "searchix" "searchix.ovh" {
            searchPath = "/";
            searchParam = "query";
          };

          "nixpkgs" = mkSearch' "nix" "search.nixos.org" {
            searchPath = "/packages";
            searchParam = "query";
            extraParams = [
              {
                name = "channel";
                value = "unstable";
              }
            ];
          };

          "erowid" = mkSearch' "erowid" "erowid.org" {
            searchPath = "/experiences/exp.cgi";
            searchParam = "Str";
            extraParams = [
              {
                name = "A";
                value = "Search";
              }
            ];
          };

          "msj" = mkSearch' "msj" "macserialjunkie.com" {
            searchPath = "/forum/search.php";
            searchParam = "keywords";
            extraParams = [
              {
                name = "sf";
                value = "titleonly";
              }
              {
                name = "sr";
                value = "topics";
              }
            ];
          };

          "csrinru" = mkSearch' "rin" "cs.rin.ru" {
            searchPath = "/forum/search.php";
            searchParam = "keywords";
            extraParams = [
              {
                name = "sf";
                value = "titleonly";
              }
              {
                name = "sr";
                value = "topics";
              }
            ];
          };
        };
      };
    };
  };
}
