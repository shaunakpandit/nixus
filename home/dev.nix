{ pkgs, ... }: {
  home.packages = with pkgs; [
    sqlite3
  ];
}
