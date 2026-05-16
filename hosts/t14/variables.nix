{ config, lib, ... }:
{
  config.var = {
    hostname = "t14";
    username = "void";
    remap = "caps:ctrl_modifier,altwin:swap_lalt_lwin";
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
