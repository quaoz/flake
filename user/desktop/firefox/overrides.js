/***************************************************************************************
 * Common Overrides - https://github.com/yokoffing/Betterfox/wiki/Common-Overrides     *
 ***************************************************************************************/

// PREF: allow websites to ask you for your location
user_pref("permissions.default.geo", 0);

// PREF: restore search engine suggestions
user_pref("browser.search.suggest.enabled", true);

/***************************************************************************************
 * Optional Hardening - https://github.com/yokoffing/Betterfox/wiki/Optional-Hardening *
 ***************************************************************************************/

// PREF: disable login manager
user_pref("signon.rememberSignons", false);

// PREF: disable address and credit card manager
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// PREF: use system dns resolver
// 0=off, 1=reserved, 2=native-fallback, 3=trr-only, 4=reserved, 5=off-by-choice
user_pref("network.trr.mode", 5);

// PREF: delete cookies, cache, and site data on shutdown
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false); // Browsing & download history
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", true); // Cookies and site data
user_pref("privacy.clearOnShutdown_v2.cache", true); // Temporary cached files and pages
user_pref("privacy.clearOnShutdown_v2.formdata", true); // Saved form info

/***************************************************************************************
 * Smoothfox - https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js           *
 ***************************************************************************************/

// credit: https://github.com/black7375/Firefox-UI-Fix
// only sharpen scrolling
user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", true); // DEFAULT
user_pref("mousewheel.min_line_scroll_amount", 10); // adjust this number to your liking; default=5
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 80); // default=50
user_pref("general.smoothScroll.currentVelocityWeighting", "0.15"); // default=.25
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6"); // default=.4
// Firefox Nightly only:
// [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1846935
user_pref("general.smoothScroll.msdPhysics.enabled", false); // [FF122+ Nightly]

/***************************************************************************************
 * My Overrides                                                                        *
 ***************************************************************************************/

// PREF: startup / new tab page
// 0=blank, 1=home, 2=last visited page, 3=resume previous session
// [SETTING] General>Startup>Open previous windows and tabs
user_pref("browser.startup.page", 3);

// PREF: don't require extensions to be signed
user_pref("xpinstall.signatures.required", false);

// PREF: enable vertical tabs
// [SETTING] General>Browser Layout>Vertical tabs
user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);
user_pref("sidebar.new-sidebar.has-used", true);
user_pref("sidebar.verticalTabs.dragToPinPromo.dismissed", true);

// PREF: don't show bookmarks
user_pref("browser.toolbars.bookmarks.visibility", "never");

// PREF: auto-enable extensions
user_pref("extensions.autoDisableScopes", 0);
