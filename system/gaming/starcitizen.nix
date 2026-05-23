{ pkgs, inputs, ... }:
{
  nix.settings = {
    substituters = [ "https://nix-citizen.cachix.org" ];
    trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
  };

  boot = {
    # see https://github.com/LovingMelody/nix-citizen/tree/main/pkgs/rsi-launcher
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };
  };

  # see https://wiki.starcitizen-lug.org/Performance-Tuning#nvidia-cache
  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE = "true";
    __GL_SHADER_DISK_CACHE_PATH = "/home/games/star-citizen/nvidiacache";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "true";
  };

  services.udev.extraRules = ''
    # grant logind uaccess to every input device
    SUBSYSTEM=="input"  , TAG+="uaccess"
    SUBSYSTEM=="hidraw" , TAG+="uaccess"

    # your existing VKB rule
    KERNEL=="hidraw*", ATTRS{idVendor}=="231d", ATTRS{idProduct}=="*", MODE="0660", TAG+="uaccess"

    # optional: always symlink your Gladiator to /dev/input/js0
    KERNEL=="js[0-9]*", ATTRS{idVendor}=="231d", ATTRS{idProduct}=="*", \
      SYMLINK+="input/js0", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    # `home.packages` if using home manager
    # replace or repeat for any included package
    inputs.nix-citizen.packages.${system}.rsi-launcher
  ];
}
