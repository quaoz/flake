{
  lib,
  pkgs,
  inputs',
  osConfig,
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

    home.sessionVariables = lib.mkIf (pkgs.stdenv.isLinux && pkgs.stdenv.isAarch64) {
      MOZ_GMP_PATH = "${firefox-widevine}/${widevinePath}";
    };

    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta;

      profiles."default" = {
        id = 0;
        isDefault = true;

        preConfig = builtins.readFile "${betterfox}/user.js";
        extraConfig =
          (builtins.readFile ./overrides.js)
          + lib.optionalString (pkgs.stdenv.isLinux && pkgs.stdenv.isAarch64) ''
            // https://github.com/AsahiLinux/widevine-installer/blob/main/conf/gmpwidevine.js
            user_pref("media.gmp-widevinecdm.version", "system-installed");
            user_pref("media.gmp-widevinecdm.visible", true);
            user_pref("media.gmp-widevinecdm.enabled", true);
            user_pref("media.gmp-widevinecdm.autoupdate", false);
            user_pref("media.eme.enabled", true);
            user_pref("media.eme.encrypted-media-encryption-scheme.enabled", true);
          '';

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
