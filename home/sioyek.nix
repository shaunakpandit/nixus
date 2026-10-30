{ config, lib, ... }:
{
  # Stylix adds toggle_custom_color; toggle_dark_mode would fight it.
  programs.sioyek.enable = true;
}
