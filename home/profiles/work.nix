# Work laptop on mango. Pair with system/profiles/work.nix.
{
  imports = [
    ./desktop.nix
    ../discord.nix
    ../work
  ];
}
