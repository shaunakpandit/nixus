{ }:
{

  programs.helium = {
    enable = true;
    defaultBrowser = true;

    extensions = [
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
      ];
    };

    # Preferences (Settings), look at the section below
    preferences = {
      browser.show_home_button = true;
      bookmark_bar.show_on_all_tabs = true;
    };
  };
}
