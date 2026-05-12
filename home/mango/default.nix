{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [
  ];

  # see https://github.com/mangowm/mango/blob/586ee8e6991e67cc1e76a84804bce7c861e0c9bb/nix/hm-modules.nix
  # for definition
  wayland.windowManager.mango = {
    enable = true;

    settings = {
      bind = [
        "SUPER,r,reload_config"
        "SUPER,q,killclient,"
        "SUPER+ALT,h,spawn,systemctl suspend"
        "SUPER+SHIFT,o,spawn,wlr-dpms on"
        "SUPER,o,toggleoverview"

        "SUPER,i,toggle_scratchpad"
        "SUPER,s,minimized"
        "SUPER+SHIFT,s,restore_minimized"

        "SUPER+SHIFT,F,togglefullscreen"
        "SUPER,f,togglemaximizescreen"
        "SUPER,t,togglefloating"
        "SUPER+SHIFT,t,centerwin"

        "SUPER,Return,spawn,ghostty"
        "SUPER,SPACE,spawn,fuzzel"
        "SUPER,b,spawn,firefox"
        "SUPER+SHIFT,b,spawn,firefox --private-window"
        "SUPER+SHIFT,m,spawn,ghostty -e btop"

        "SUPER+CTRL,h,scroller_stack,left"
        "SUPER+CTRL,j,scroller_stack,down"
        "SUPER+CTRL,k,scroller_stack,up"
        "SUPER+CTRL,l,scroller_stack,right"
        "SUPER,h,focusdir,left"
        "SUPER,j,focusdir,down"
        "SUPER,k,focusdir,up"
        "SUPER,l,focusdir,right"

        "SUPER,1,view,1"
        "SUPER,2,view,2"
        "SUPER,3,view,3"
        "SUPER,4,view,4"
        "SUPER,5,view,5"

        "SUPER+SHIFT,n,switch_layout"

        "SUPER+SHIFT,1,tagsilent,1"
        "SUPER+SHIFT,2,tagsilent,2"
        "SUPER+SHIFT,3,tagsilent,3"
        "SUPER+SHIFT,4,tagsilent,4"
        "SUPER+SHIFT,5,tagsilent,5"

        "SUPER+SHIFT,h,exchange_client,left"
        "SUPER+SHIFT,j,exchange_client,down"
        "SUPER+SHIFT,k,exchange_client,up"
        "SUPER+SHIFT,l,exchange_client,right"

        "NONE,XF86MonBrightnessUp,spawn,brightnessctl s +2%"
        "SHIFT,XF86MonBrightnessUp,spawn,brightnessctl s 100%"
        "NONE,XF86MonBrightnessDown,spawn,brightnessctl s 2%-"
        "SHIFT,XF86MonBrightnessDown,spawn,brightnessctl s 1%"
        "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%+"
        "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%-"
        "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SINK@ toggle"
        "SHIFT,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SOURCE@ toggle"
        "SUPER,p,spawn,playerctl play-pause"

        "SUPER+SHIFT,Return,toggle_named_scratchpad,none,term-scratch,ghostty --title=term-scratch -e sh -lc 'tmux new-session -A -s temp -n scratch'"
        "SUPER,m,toggle_named_scratchpad,none,btop-scratch,ghostty --title=btop-scratch -e btop"
        "SUPER,n,toggle_named_scratchpad,none,notes-scratch,ghostty --title=notes-scratch -e sh -lc 'tmux new-session -A -s notes -c \"$HOME/pkm\" nvim'"
        "SUPER+SHIFT,t,toggle_named_scratchpad,none,SillyTavern*, firefox --private-window 192.168.4.28:8000"
      ];

      windowrule = [
        "isnamedscratchpad:1,width:1000,height:700,title:term-scratch"
        "isnamedscratchpad:1,width:1000,height:700,title:btop-scratch"
        "isnamedscratchpad:1,width:1000,height:700,title:notes-scratch"
        "isnamedscratchpad:1,width:400,height:600,title:SillyTavern*"
      ];

      enable_hotarea = 0;
      overviewgappo = 5;

      repeat_rate = 70;
      repeat_delay = 200;

      xkb_rules_layout = "us";
      xkb_rules_options = "caps:ctrl_modifier,altwin:swap_lalt_lwin";

      trackpad_natural_scrolling = 1;
      borderpx = 2;
      blur = 1;
      focused_opacity = 0.92;
      unfocused_opacity = 0.87;

      cursor_size = 32;
      cursor_theme = "phingers-cursors-dark";

      bordercolor = "0x${c.base03}ff";
      focuscolor = "0x${c.base0B}ff";
      urgentcolor = "0x${c.base08}ff";

      new_is_master = 0;

      tagrule = [
        "id:1,layout_name:right_tile"
        "id:2,layout_name:vertical_scroller"
        "id:3,layout_name:right_tile"
        "id:4,layout_name:right_tile"
      ];

      gesturebind = [
        "none,left,3,focusdir,left"
        "none,right,3,focusdir,right"
        "none,up,3,focusdir,up"
        "none,down,3,focusdir,down"
        "none,left,4,viewtoleft_have_client"
        "none,right,4,viewtoright_have_client"
        "none,up,4,toggleoverview"
        "none,down,4,toggleoverview"
      ];
    };

    autostart_sh = ''
      waybar &
      swaybg -i ~/dev/nixos/walls/solar.png &
    '';
  };
}
