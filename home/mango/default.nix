{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [
  ];

  wayland.windowManager.mango = {
    enable = true;
    settings = ''
      		bind=SUPER,r,reload_config
      		bind=SUPER,Return,spawn,ghostty
      		bind=SUPER,SPACE,spawn,fuzzel
      		bind=SUPER,q,killclient,
      		bind=SUPER,b,spawn,firefox
      		bind=SUPER+SHIFT,b,spawn,firefox --private-window
      		bind=SUPER+SHIFT,m,spawn,ghostty -e btop
      		bind=SUPER+CTRL,h,scroller_stack,left
      		bind=SUPER+CTRL,j,scroller_stack,down
      		bind=SUPER+CTRL,k,scroller_stack,up
      		bind=SUPER+CTRL,l,scroller_stack,right	
      		bind=SUPER,h,focusdir,left
      		bind=SUPER,j,focusdir,down
      		bind=SUPER,k,focusdir,up
      		bind=SUPER,l,focusdir,right	
      		bind=SUPER,1,view,1
      		bind=SUPER,2,view,2
      		bind=SUPER,3,view,3
      		bind=SUPER,4,view,4
      		bind=SUPER,5,view,5
            bind=SUPER+SHIFT,n,switch_layout
      		bind=SUPER+SHIFT,1,tagsilent,1	
      		bind=SUPER+SHIFT,2,tagsilent,2	
      		bind=SUPER+SHIFT,3,tagsilent,3	
      		bind=SUPER+SHIFT,4,tagsilent,4	
      		bind=SUPER+SHIFT,5,tagsilent,5	
      		bind=SUPER+SHIFT,h,exchange_client,left
      		bind=SUPER+SHIFT,j,exchange_client,down
      		bind=SUPER+SHIFT,k,exchange_client,up
      		bind=SUPER+SHIFT,l,exchange_client,right	
            bind=SUPER,f,togglemaximizescreen
            bind=SUPER+SHIFT,F,togglefullscreen
            bind=SUPER,t,togglefloating
            bind=SUPER+SHIFT,t,centerwin
            bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl s +2%
            bind=SHIFT,XF86MonBrightnessUp,spawn,brightnessctl s 100%
            bind=NONE,XF86MonBrightnessDown,spawn,brightnessctl s 2%-
            bind=SHIFT,XF86MonBrightnessDown,spawn,brightnessctl s 1%
            bind=NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%+
            bind=NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%-
            bind=NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SINK@ toggle
            bind=SHIFT,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SOURCE@ toggle
            bind=SUPER,p,spawn,playerctl next
            bind=SUPER,i,spawn,playerctl previous
            bind=SUPER,o,spawn,playerctl play-pause
      		repeat_rate=70
      		repeat_delay=200
      		xkb_rules_layout=us
      		xkb_rules_options=caps:ctrl_modifier,altwin:swap_lalt_lwin
            trackpad_natural_scrolling=1
            borderpx=2
            blur=1
            focused_opacity=.92
            unfocused_opacity=.87
            cursor_size = 28
            bordercolor=0x${c.base03}ff
            focuscolor=0x${c.base0B}ff
            urgentcolor=0x${c.base08}ff
            new_is_master=0
            tagrule=id:1,layout_name:right_tile
            tagrule=id:2,layout_name:vertical_scroller
            tagrule=id:3,layout_name:right_tile
            tagrule=id:4,layout_name:right_tile
            gesturebind=none,left,3,focusdir,left
            gesturebind=none,right,3,focusdir,right
            gesturebind=none,up,3,focusdir,up
            gesturebind=none,down,3,focusdir,down
            gesturebind=none,left,4,viewtoleft_have_client
            gesturebind=none,right,4,viewtoright_have_client
            gesturebind=none,up,4,toggleoverview
            gesturebind=none,down,4,toggleoverview
            bind=SUPER+ALT,h,spawn,systemctl suspend
            bind=SUPER+SHIFT,o,spawn,wlr-dpms on
            cursor_size=32
            cursor_theme=phingers-cursors-dark
    '';
    autostart_sh = ''
      waybar &
      swaybg -i ~/dev/nixos/walls/solar.png &
    '';
  };
}
