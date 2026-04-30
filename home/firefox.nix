{
  config,
  pkgs,
  inputs,
  ...
}:
let
  c = config.lib.stylix.colors;
in
{

  programs.firefox = {
    enable = true;
    profiles = {
      void = {
        isDefault = true;
        extensions = {
          force = true;

          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            ublock-origin
            darkreader
            proton-pass
            vimium
          ];
        };
        settings = {
          # Optional if you ever use userChrome/userContent.css
          # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          ### Tracking / telemetry / Firefox data collection
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.sessions.current.clean" = true;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.ping-centre.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.tabs.crashReporting.sendReport" = false;
          "breakpad.reportURL" = "";

          ### Tracking protection
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.pbmode.enabled" = true;
          "browser.contentblocking.category" = "strict";

          ### Fingerprinting resistance
          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.pbmode" = true;
          "webgl.disabled" = true;

          ### WebRTC IP leak reduction
          "media.peerconnection.enabled" = false;

          ### DNS / network privacy
          # Disable Firefox DNS-over-HTTPS so it does NOT resolve through Mozilla/partner DoH
          "network.trr.mode" = 5;

          ### Search / suggestions / URL bar leaking typed text
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.quicksuggest.enabled" = false;
          "browser.urlbar.quicksuggest.sponsored" = false;
          "browser.urlbar.groupLabels.enabled" = false;

          ### Prefetching / speculative connections
          "network.dns.disablePrefetch" = true;
          "network.prefetch-next" = false;
          "network.predictor.enabled" = false;
          "network.predictor.enable-prefetch" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;

          ### Referrer trimming
          "network.http.referer.XOriginPolicy" = 2;
          "network.http.referer.XOriginTrimmingPolicy" = 2;

          ### Cookies / site isolation
          "network.cookie.cookieBehavior" = 5;

          ### HTTPS-only
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;

          ### Safe browsing / remote checks
          # More private, but reduces phishing/malware protection.
          # If you want max privacy, keep false. If you want some protection, remove these.
          "browser.safebrowsing.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;

          ### Pocket / sponsored / Mozilla online features
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          ### Misc privacy hardening
          "beacon.enabled" = false;
          "dom.battery.enabled" = false;
          "geo.enabled" = false;

          ### Session / history behavior
          # Set these how strict you want:
          "privacy.clearOnShutdown.cache" = true;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.formdata" = true;
          "privacy.clearOnShutdown.offlineApps" = true;
          "privacy.clearOnShutdown.sessions" = false;
          "privacy.sanitize.sanitizeOnShutdown" = false;
        };
      };
    };
  };

  stylix.targets.firefox = {
    enable = true;
    colorTheme.enable = true;
    colors.enable = true;
    fonts.enable = true;
    profileNames = [ "void" ];
  };
}
