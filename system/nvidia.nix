{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  # from CachyOS: skip zeroing system memory before handing it to the GPU
  boot.extraModprobeConfig = "options nvidia NVreg_InitializeSystemMemoryAllocations=0";

  hardware.nvidia = {

    # the default (stable) tracks the production branch, which lags behind new_feature
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.latest;

    # Modesetting is required.
    modesetting.enable = true;

    # Saves all of VRAM across suspend. Without it Wayland sessions come back
    # with graphical corruption or crashed apps.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;
  };
}
