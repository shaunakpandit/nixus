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
    defaultBrowser = true;

    # id="dbepggeogbaibhgnhhndojpepiihcmeb"
    # url="https://clients2.google.com/service/update2/crx?response=redirect&prodversion=131.0&acceptformat=crx2,crx3&x=id%3D${id}%26uc"
    # curl -L -o "$id.crx" "$url" && nix hash file "$id.crx"
    extensions = [
      # darkreader: eimadpbcbfnmbkopoojfekhnkhdbieeh
      {
        id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
        hash = "sha256-jAhpgyVucHif6fJ2VUJoOtPAcHUh7BdAEMr9JpdocBY=";
      }

      # vimium: dbepggeogbaibhgnhhndojpepiihcmeb
      {
        id = "dbepggeogbaibhgnhhndojpepiihcmeb";
        hash = "sha256-MZjCaqcZvkYt6lhQUPvtm4uAYo1X6oihE7q/UzTFUXw=";
      }
      # protonPass: ghmbeldphafepmbegfdlkpapadhbakde
      {
        id = "ghmbeldphafepmbegfdlkpapadhbakde";
        hash = "sha256-Xfm9bbdufzfHWhmtYThWL+n2RfVavr3IjxxOTY0P4Ug=";
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
