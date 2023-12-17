// Dont clear history
user_pref("privacy.clearOnShutdown.history", false);

// Start firefox with last session, requires history not be cleared
user_pref("browser.startup.page", 3); 

// Enable web search in address bar
user_pref("keyword.enabled", true);

// Disable the Twitter/Reddit/Facebook ads in the URL bar:
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.suggest.topsites", false);

// Do not prefil forms:
user_pref("signon.prefillForms", false);

// Do not autocomplete in the URL bar:
user_pref("browser.urlbar.autoFill", false);

// Allow access to http (i.e. not https) sites:
//user_pref("dom.security.https_only_mode", false);

// Keep cookies until expiration or user deletion:
// user_pref("network.cookie.lifetimePolicy", 0);


// Disable push notifications:
//user_pref("dom.webnotifications.serviceworker.enabled", false);
//user_pref("dom.push.enabled", false);

// Disable Firefox sync and its menu entries
user_pref("identity.fxaccounts.enabled", false);

// Disable the pocket antifeature:
user_pref("extensions.pocket.enabled", false);

// Don't autodelete cookies on shutdown:
//user_pref("privacy.clearOnShutdown.cookies", false);

// Enable custom userChrome.js:
//user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// This could otherwise cause some issues on bank logins and other annoying sites:
//user_pref("network.http.referer.XOriginPolicy", 0);

