{
  lib,
  pkgs,
  inputs',
  osConfig,
  config,
  ...
}: let
  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "146.0";
    hash = "sha256-zGpfQk2gY6ifxIk1fvCk5g5SIFo+o8RItmw3Yt3AeCg=";
  };

  # enable widevine on aarch64 linux (test: https://bitmovin.com/demos/drm)
  #
  # WATCH: https://github.com/nix-community/nixos-apple-silicon/issues/145
  # WATCH: https://github.com/NixOS/nixpkgs/issues/338245
  widevinePath = "gmp-widevinecdm/system-installed";

  firefox-widevine = pkgs.stdenv.mkDerivation {
    name = "firefox-widevine";
    inherit (pkgs.widevine-cdm) version;

    buildCommand = let
      widevineSrc = "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm";
    in ''
      mkdir -p "$out/${widevinePath}"
      ln -s "${widevineSrc}/_platform_specific/linux_arm64/libwidevinecdm.so" "$out/${widevinePath}/libwidevinecdm.so"
      ln -s "${widevineSrc}/manifest.json" "$out/${widevinePath}/manifest.json"
    '';
  };
in {
  config = lib.mkIf osConfig.garden.profiles.desktop.enable {
    stylix.targets.firefox = {
      profileNames = ["default"];
      colorTheme.enable = true;
    };

    home = {
      sessionVariables = lib.mkIf (pkgs.stdenv.isLinux && pkgs.stdenv.isAarch64) {
        MOZ_GMP_PATH = "${firefox-widevine}/${widevinePath}";
      };

      # prepend betterfox user js to config
      file."${config.programs.firefox.profilesPath}/default/user.js".source = pkgs.concatText "user.js" [
        "${betterfox}/user.js"
        (builtins.toFile "hm-user.js" config.home.file."${config.programs.firefox.profilesPath}/default/user.js".text)
      ];
    };

    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta;

      profiles."default" = {
        id = 0;
        isDefault = true;

        settings =
          {
            # allow websites to ask you for your location
            "permissions.default.geo" = 0;
            # restore search engine suggestions
            "browser.search.suggest.enabled" = true;

            ## Optional Hardening - https://github.com/yokoffing/Betterfox/wiki/Optional-Hardening

            # disable login manager
            "signon.rememberSignons" = false;
            # disable address and credit card manager
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            # use system dns resolver
            "network.trr.mode" = 5;
            # delete cookies, cache, and site data on shutdown
            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
            "privacy.clearOnShutdown_v2.cache" = true;
            "privacy.clearOnShutdown_v2.formdata" = true;

            ## Smoothfox - https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js

            "apz.overscroll.enabled" = true;
            "general.smoothScroll" = true;
            "mousewheel.min_line_scroll_amount" = 10;
            "general.smoothScroll.mouseWheel.durationMinMS" = 80;
            "general.smoothScroll.currentVelocityWeighting" = "0.15";
            "general.smoothScroll.stopDecelerationWeighting" = "0.6";
            "general.smoothScroll.msdPhysics.enabled" = false;

            ## My Overrides

            # resume previous session
            "browser.startup.page" = 3;
            # don't require extensions to be signed
            "xpinstall.signatures.required" = false;
            # enable vertical tabs
            "sidebar.revamp" = true;
            "sidebar.verticalTabs" = true;
            "sidebar.new-sidebar.has-used" = true;
            "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
            # don't show bookmarks
            "browser.toolbars.bookmarks.visibility" = "never";
            # auto-enable extensions
            "extensions.autoDisableScopes" = 0;
          }
          // lib.mkIf (pkgs.stdenv.isLinux && pkgs.stdenv.isAarch64) {
            # https://github.com/AsahiLinux/widevine-installer/blob/main/conf/gmpwidevine.js
            "media.gmp-widevinecdm.version" = "system-installed";
            "media.gmp-widevinecdm.visible" = true;
            "media.gmp-widevinecdm.enabled" = true;
            "media.gmp-widevinecdm.autoupdate" = false;
            "media.eme.enabled" = true;
            "media.eme.encrypted-media-encryption-scheme.enabled" = true;
          };

        extensions = {
          force = true;

          packages = with inputs'.firefox-addons.packages; [
            # keep-sorted start
            auto-tab-discard
            bitwarden
            blocktube
            buster-captcha-solver
            control-panel-for-twitter
            custom-new-tab-page
            darkreader
            don-t-fuck-with-paste
            ff2mpv
            indie-wiki-buddy
            justdeleteme
            search-by-image
            single-file
            sponsorblock
            terms-of-service-didnt-read
            translate-web-pages
            ublacklist
            ublock-origin
            unpaywall
            violentmonkey
            wayback-machine
            web-scrobbler
            # keep-sorted end
          ];
        };

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
  };
}
