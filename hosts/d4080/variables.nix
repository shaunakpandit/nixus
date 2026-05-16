{ config, lib, ... }:
{
  config.var = {
    hostname = "d4080";
    username = "void";
    remap = "";
  };
  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
