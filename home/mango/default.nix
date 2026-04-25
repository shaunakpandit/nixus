{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
in
{
  wayland.windowManager.mango = {
    enable = true;
    settings = ''
      		bind=SUPER,r,reload_config
      		bind=SUPER,Return,spawn,ghostty
      		bind=SUPER,d,spawn,wmenu-run -l 10
      		bind=SUPER,q,killclient,
      		bind=SUPER,b,spawn,firefox
      		bind=SUPER,h,focusdir,left
      		bind=SUPER,j,focusdir,down
      		bind=SUPER,k,focusdir,up
      		bind=SUPER,l,focusdir,right	
      		bind=SUPER,1,view,1
      		bind=SUPER,2,view,2
      		bind=SUPER,3,view,3
      		bind=SUPER,4,view,4
      		bind=SUPER,5,view,5
      		bind=SUPER+SHIFT,1,tagsilent,1	
      		bind=SUPER+SHIFT,2,tagsilent,2	
      		bind=SUPER+SHIFT,3,tagsilent,3	
      		bind=SUPER+SHIFT,4,tagsilent,4	
      		bind=SUPER+SHIFT,5,tagsilent,5	
      		bind=SUPER+SHIFT,h,exchange_client,left
      		bind=SUPER+SHIFT,j,exchange_client,down
      		bind=SUPER+SHIFT,k,exchange_client,up
      		bind=SUPER+SHIFT,l,exchange_client,right	
      		repeat_rate=70
      		repeat_delay=200
      		xkb_rules_layout=us
      		xkb_rules_options=caps:ctrl_modifier,altwin:swap_lalt_lwin
            borderpx=2
            blur=1
            focused_opacity=.92
            unfocused_opacity=.87
            cursor_size = 28
            bordercolor=0x${c.base03}ff
            focuscolor=0x${c.base0B}ff
            urgentcolor=0x${c.base08}ff
    '';
    autostart_sh = ''
      waybar &
      swaybg -i ~/dev/nixos/walls/solar.png &
    '';
  };
}
