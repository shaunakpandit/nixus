{
  config,
  pkgs,
  lib,
  ...
}:
let
  c = config.lib.stylix.colors;
  signal = 8;

  # Prints the waybar status, or flips between neutral and warm with `toggle`.
  nightlight = pkgs.writeShellApplication {
    name = "nightlight";
    runtimeInputs = [
      pkgs.systemd
      pkgs.procps
    ];
    text = ''
      temperature=(rs.wl-gammarelay / rs.wl.gammarelay Temperature)
      current=$(busctl --user get-property "''${temperature[@]}" 2>/dev/null || echo "q 6500")
      current=''${current#q }

      if [ "''${1:-}" = toggle ]; then
        if [ "$current" -lt 6500 ]; then target=6500; else target=4000; fi
        busctl --user set-property "''${temperature[@]}" q "$target"
        pkill -RTMIN+${toString signal} waybar || true
      elif [ "$current" -lt 6500 ]; then
        echo '{"text": "🌙", "class": "on", "tooltip": "Night mode on"}'
      else
        echo '{"text": "🌙", "class": "off", "tooltip": "Night mode off"}'
      fi
    '';
  };
in
{
  # Holds the gamma ramp for the session and exposes it over D-Bus.
  systemd.user.services.wl-gammarelay = {
    Unit = {
      Description = "Display color temperature control";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
    };
    Service = {
      Type = "dbus";
      BusName = "rs.wl-gammarelay";
      ExecStart = lib.getExe pkgs.wl-gammarelay-rs;
      Restart = "on-failure";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  programs.waybar = {
    settings.mainBar = {
      modules-right = [ "custom/nightlight" ];
      "custom/nightlight" = {
        exec = lib.getExe nightlight;
        on-click = "${lib.getExe nightlight} toggle";
        return-type = "json";
        interval = "once";
        inherit signal;
      };
    };
    style = ''
      #custom-nightlight.on {
        color: #${c.base0A};
      }
      #custom-nightlight.off {
        opacity: 0.5;
      }
    '';
  };
}
