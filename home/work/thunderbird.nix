# Outlook replacement. Add the Exchange account in Thunderbird's account wizard (OAuth login).
{
  programs.thunderbird = {
    enable = true;
    profiles.work.isDefault = true;
  };
}
