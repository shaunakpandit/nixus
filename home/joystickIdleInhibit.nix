{ pkgs, lib, ... }:
let
  # Compositors only count keyboard/mouse as activity, so gamepad- or
  # HOTAS-only play would blank the screens. Hold a Wayland idle inhibitor
  # while any joystick is in use. Reading /dev/input needs the `input` group.
  joystickIdleInhibit =
    pkgs.writers.writePython3Bin "joystick-idle-inhibit"
      {
        libraries = [ pkgs.python3Packages.evdev ];
        flakeIgnore = [ "E501" ];
      }
      ''
        import os
        import select
        import subprocess
        import time

        import evdev
        from evdev import ecodes

        WLINHIBIT = "${lib.getExe' pkgs.wlinhibit "wlinhibit"}"
        GRACE_SECONDS = 30
        RESCAN_SECONDS = 5
        # Fraction of an axis range a value must move to count, so stick drift
        # and sensor noise don't keep the screens on forever.
        AXIS_DEADBAND = 0.03


        def is_joystick(device):
            keys = device.capabilities().get(ecodes.EV_KEY, [])
            return any(ecodes.BTN_JOYSTICK <= key < ecodes.BTN_DIGI or key >= ecodes.BTN_TRIGGER_HAPPY for key in keys)


        # The inode tells apart a new device that reuses an unplugged one's path.
        def node_ids(paths):
            for path in paths:
                try:
                    yield (path, os.stat(path).st_ino)
                except OSError:
                    pass


        def scan(devices, seen):
            nodes = set(node_ids(evdev.list_devices()))
            for node in seen - nodes:
                device = devices.pop(node, None)
                if device:
                    device.close()
            for node in nodes - seen:
                try:
                    device = evdev.InputDevice(node[0])
                except OSError:
                    continue
                if is_joystick(device):
                    devices[node] = device
                else:
                    device.close()
            return nodes


        def is_activity(device, axes, event):
            if event.type == ecodes.EV_KEY:
                return True
            if event.type != ecodes.EV_ABS:
                return False
            info = device.absinfo(event.code)
            key = (device.path, event.code)
            last = axes.setdefault(key, event.value)
            if abs(event.value - last) > (info.max - info.min) * AXIS_DEADBAND:
                axes[key] = event.value
                return True
            return False


        def main():
            devices, seen, axes = {}, set(), {}
            inhibitor = None
            last_activity = next_scan = 0.0
            while True:
                if time.monotonic() >= next_scan:
                    seen = scan(devices, seen)
                    next_scan = time.monotonic() + RESCAN_SECONDS
                readable, _, _ = select.select(list(devices.values()), [], [], 1)
                for node, device in [item for item in devices.items() if item[1] in readable]:
                    try:
                        if any([is_activity(device, axes, event) for event in device.read()]):
                            last_activity = time.monotonic()
                    except OSError:
                        devices.pop(node).close()
                if inhibitor and inhibitor.poll() is not None:
                    inhibitor = None
                active = time.monotonic() - last_activity < GRACE_SECONDS
                if active and not inhibitor:
                    inhibitor = subprocess.Popen([WLINHIBIT])
                elif not active and inhibitor:
                    inhibitor.terminate()
                    inhibitor.wait()
                    inhibitor = None


        main()
      '';
in
{
  systemd.user.services.joystick-idle-inhibit = {
    Unit = {
      Description = "Inhibit idle while a joystick or gamepad is in use";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = lib.getExe joystickIdleInhibit;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
