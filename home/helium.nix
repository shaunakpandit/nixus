{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # see https://gitlab.com/ntgn/helium-flake
  # for configuration
  programs.helium = {
    enable = true;
    defaultBrowser = false;

    # id="dbepggeogbaibhgnhhndojpepiihcmeb"
    # url="https://clients2.google.com/service/update2/crx?response=redirect&prodversion=131.0&acceptformat=crx2,crx3&x=id%3D${id}%26uc"
    # curl -L -o "$id.crx" "$url" && nix hash file "$id.crx"
    extensions = [
      # darkreader: eimadpbcbfnmbkopoojfekhnkhdbieeh
      {
        id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
        hash = "sha256-ncsb1tytQ4kt3AKP9l+YLfPtuhNammRF5PpxZx43qhM=";
      }

      # vimium: dbepggeogbaibhgnhhndojpepiihcmeb
      {
        id = "dbepggeogbaibhgnhhndojpepiihcmeb";
        hash = "sha256-MZjCaqcZvkYt6lhQUPvtm4uAYo1X6oihE7q/UzTFUXw=";
      }
      # protonPass: ghmbeldphafepmbegfdlkpapadhbakde
      {
        id = "ghmbeldphafepmbegfdlkpapadhbakde";
        hash = "sha256-LMVNciGP4JCB6OOCYa4PFqylHGJyKCj0ajMQn4jHxnk=";
      }
    ];

    # These flags get added to the wrapper
    extraFlags = [
      "--force-dark-mode"
    ];

    # These get merged into the policy file in /etc
    extraPolicies = {
      HomepageLocation = "https://google.com";
      PasswordManagerEnabled = false;
      DeveloperToolsAvailability = 1; # Ensures 'Inspect Element' works
      ManagedBookmarks = [
        {
          toplevel_name = "Nix Ecosystem";
        }
        {
          url = "https://search.nixos.org/packages";
          name = "Nix Packages";
        }
        {
          url = "https://home-manager-options.extranix.com/?query=&release=master";
          name = "Homemanager Packages";
        }
        {
          url = "https://mangowm.github.io/docs/configuration";
          name = "Mango";
        }
      ];
    };

    # Preferences (Settings), look at the section below
    preferences = {
      browser.show_home_button = true;
      bookmark_bar.show_on_all_tabs = true;
    };
  };
}
