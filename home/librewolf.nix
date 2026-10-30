{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;

  # thoth's LAN address. It is also advertised as a tailscale subnet route
  # (system/tailscale.nix), so the same links work away from home.
  thoth = "192.168.4.28";

  # Keep in sync with containers/ and the firewall in hosts/thoth/configuration.nix.
  sections = [
    {
      title = "thoth";
      groups = [
        {
          name = "media";
          links = [
            {
              name = "Plex";
              url = "http://${thoth}:32400/web";
              note = ":32400";
            }
            {
              name = "Grimmory";
              url = "http://${thoth}:6060";
              note = ":6060";
            }
          ];
        }
        {
          name = "ai";
          links = [
            {
              name = "Open WebUI";
              url = "http://${thoth}:3000";
              note = ":3000";
            }
          ];
        }
        {
          name = "games";
          links = [
            {
              name = "Crafty Controller";
              url = "https://${thoth}:8443";
              note = ":8443";
            }
            {
              name = "Dynmap";
              url = "http://${thoth}:8123";
              note = ":8123";
            }
          ];
        }
      ];
    }
    {
      title = "links";
      groups = [
        {
          name = "nix";
          links = [
            {
              name = "NixOS options";
              url = "https://search.nixos.org/options?channel=unstable";
              note = "search.nixos.org";
            }
            {
              name = "Home Manager";
              url = "https://home-manager-options.extranix.com/?release=master";
              note = "extranix.com";
            }
          ];
        }
        {
          name = "desktop";
          links = [
            {
              name = "Mango config";
              url = "https://mangowm.github.io/docs/configuration";
              note = "mangowm.github.io";
            }
          ];
        }
        {
          name = "ai";
          links = [
            {
              name = "WebUI";
              url = "https://webui.jssp.io";
              note = "webui.jssp.io";
            }
            {
              name = "OpenRouter";
              url = "https://openrouter.ai";
              note = "openrouter.ai";
            }
          ];
        }
      ];
    }
  ];

  renderLink = l: ''
    <a href="${l.url}"><span>${l.name}</span><span class="note">${l.note}</span></a>
  '';
  renderGroup = g: ''
    <div class="group">
      <h3>${g.name}</h3>
      ${lib.concatMapStrings renderLink g.links}
    </div>
  '';
  renderSection = s: ''
    <section>
      <h2>${s.title}</h2>
      <div class="groups">${lib.concatMapStrings renderGroup s.groups}</div>
    </section>
  '';

  # Self-contained (no remote fonts or scripts) so it loads offline and leaks nothing.
  homepage = pkgs.writeText "librewolf-home.html" ''
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>home</title>
      <style>
        :root { color-scheme: dark; }
        body {
          margin: 0;
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          background: ${c.base00};
          color: ${c.base05};
          font-family: "${config.stylix.fonts.monospace.name}", monospace;
        }
        main { width: min(960px, 90vw); }
        h1 { color: ${c.base0B}; font-weight: normal; margin-bottom: 2rem; }
        section + section { margin-top: 2.5rem; }
        h2 {
          font-size: 0.9rem;
          font-weight: normal;
          color: ${c.base04};
          border-bottom: 1px solid ${c.base02};
          padding-bottom: 0.4rem;
        }
        .groups {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 1rem;
        }
        h3 { font-size: 0.8rem; font-weight: normal; color: ${c.base03}; margin: 0 0 0.5rem; }
        a {
          display: flex;
          justify-content: space-between;
          gap: 1rem;
          padding: 0.5rem 0.75rem;
          margin-bottom: 0.35rem;
          background: ${c.base01};
          color: ${c.base05};
          text-decoration: none;
          border-left: 2px solid transparent;
        }
        a:hover, a:focus {
          background: ${c.base02};
          color: ${c.base0B};
          border-left-color: ${c.base0B};
          outline: none;
        }
        .note { color: ${c.base04}; font-size: 0.8rem; }
      </style>
    </head>
    <body>
      <main>
        <h1>${config.var.username}@${config.var.hostname}</h1>
        ${lib.concatMapStrings renderSection sections}
      </main>
    </body>
    </html>
  '';
in
{
  # LibreWolf already ships the hardening and telemetry removal that
  # firefox.nix set by hand, so the settings here only cover preferences
  # and the defaults that are too painful for a daily driver.
  programs.librewolf = {
    enable = true;
    profiles.void = {
      isDefault = true;

      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          proton-pass
          vimium
        ];
      };

      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
        engines = {
          "NixOS Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home Manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "release";
                    value = "master";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
        };
      };

      settings = {
        "browser.startup.page" = 1;
        "browser.startup.homepage" = "file://${homepage}";

        # for stylix to work
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layout.css.prefers-color-scheme.content-override" = 0;

        # Extensions are pinned by flake.lock and updated with
        # `nix flake update`, so enable them without a prompt and don't let
        # the browser update them (a rebuild would revert it anyway).
        "extensions.autoDisableScopes" = 0;
        "extensions.update.enabled" = false;

        # resistFingerprinting forces light mode, UTC and letterboxing, which
        # defeats stylix and breaks a lot of sites. Fingerprinting protection
        # (what Firefox's strict mode uses) keeps most of the benefit.
        "privacy.resistFingerprinting" = false;
        "privacy.fingerprintingProtection" = true;

        # LibreWolf wipes cookies and history on every exit, which logs you out
        # of everything. Third-party tracking is still handled by strict
        # tracking protection and uBlock Origin.
        "privacy.sanitize.sanitizeOnShutdown" = false;

        # HTTPS-only stays on (LibreWolf default), but private IPs are exempt so
        # the plain-http services on thoth open without an interstitial.
        "dom.security.https_only_mode.upgrade_local" = false;

        # Proton Pass handles passwords and autofill
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # Ask where to save each download
        "browser.download.useDownloadDir" = false;
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.genAttrs [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ] (_: "librewolf.desktop");
  };

  stylix.targets.librewolf = {
    enable = true;
    colorTheme.enable = true;
    colors.enable = true;
    fonts.enable = true;
    profileNames = [ "void" ];
  };
}
