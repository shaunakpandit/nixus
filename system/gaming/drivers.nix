{ config, pkgs, ... }:
{
  # from: https://medium.com/@notquitethereyet_/gaming-on-nixos-%EF%B8%8F-f98506351a24
  hardware.graphics = {
    # Enable OpenGL and 32bit libs
    enable = true;
    enable32Bit = true;
    # Extra packages for 64-bit
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
      libGL
      libGLU # for very old pre-2005 OpenGL games
    ];
    # Extra packages for 32-bit
    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa
      vulkan-loader
      libGL
      libGLU # for very old pre-2005 OpenGL games
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  ## for nvidia, see medium article linked above
}
