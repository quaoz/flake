/****************************************************************************
 * START: MY OVERRIDES                                                      *
 ****************************************************************************/
// PREF: preferred colour scheme for websites and sub-pages
// Dark (0), Light (1), System (2), Browser (3)
user_pref("layout.css.prefers-colour-scheme.content-override", 0);

// PREF: restore search engine suggestions
user_pref("browser.search.suggest.enabled", true);

// PREF: disable Firefox Sync
user_pref("identity.fxaccounts.enabled", false);

// PREF: disable login manager
user_pref("signon.rememberSignons", false);

// PREF: disable address and credit card manager
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// PREF: delete cookies, cache, and site data on shutdown
user_pref("privacy.sanitise.sanitiseOnShutdown", true);
user_pref("privacy.clearOnShutdown_v2.cache", true); // DEFAULT
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", true); // DEFAULT
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);

// PREF: startup / new tab page
// 0=blank, 1=home, 2=last visited page, 3=resume previous session
// [NOTE] Session Restore is cleared with history and not used in Private Browsing mode
// [SETTING] General>Startup>Open previous windows and tabs
user_pref("browser.startup.page", 3);

// PREF: disable auto-INSTALLING Firefox updates [NON-WINDOWS]
// [NOTE] In FF65+ on Windows this SETTING (below) is now stored in a file and the pref was removed.
// [SETTING] General>Firefox Updates>Check for updates but let you choose to install them
user_pref("app.update.auto", false);

// PREF: use same search engine for Private Windows
// [SETTINGS] Preferences>Search>Default Search Engine>"Use this search engine in Private Windows"
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);
// [SETTINGS] "Choose a different default search engine for Private Windows only"
user_pref("browser.search.separatePrivateDefault", false);

// PREF: use system dns resolver
// 0=off, 1=reserved, 2=native-fallback, 3=trr-only, 4=reserved, 5=off-by-choice
user_pref("network.trr.mode", 5);

// PREF: JPEG XL image format [NIGHTLY]
// May not affect anything on ESR/Stable channel [2].
// [TEST] https://www.jpegxl.io/firefox#firefox-jpegxl-tutorial
// [1] https://cloudinary.com/blog/the-case-for-jpeg-xl
// [2] https://bugzilla.mozilla.org/show_bug.cgi?id=1539075#c51
user_pref("image.jxl.enabled", true);

// PREF: enable WebRTC Global Mute Toggles [NIGHTLY]
user_pref("privacy.webrtc.globalMuteToggles", true);

// PREF: don't require extensions to be signed
user_pref("xpinstall.signatures.required", false);

/****************************************************************************
 * SECTION: SMOOTHFOX                                                       *
 ****************************************************************************/
// visit https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js
// Enter your scrolling overrides below this line:

// credit: https://github.com/black7375/Firefox-UI-Fix
// only sharpen scrolling
user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", true); // DEFAULT
user_pref("mousewheel.min_line_scroll_amount", 10); // 10-40; adjust this number to your liking; default=5
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 80); // default=50
user_pref("general.smoothScroll.currentVelocityWeighting", "0.15"); // default=.25
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6"); // default=.4
// Firefox Nightly only:
// [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1846935
user_pref("general.smoothScroll.msdPhysics.enabled", false); // [FF122+ Nightly]

/****************************************************************************
 * END: BETTERFOX                                                           *
 ****************************************************************************/
