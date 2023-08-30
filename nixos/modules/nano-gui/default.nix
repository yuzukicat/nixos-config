{
  services.xserver = {
    enable = true;
    autorun = true;
    windowManager.dwm.enable = true;
    displayManager.startx.enable = true;
    displayManager.defaultSession = "none+dwm";
    # --output HDMI-0 --same-as DP-2 --mode 1920x1080 --brightness 1.0 --rotate normal
    displayManager.sessionCommands = ''
      xrandr --output DP-2 --primary --mode 2560x1600 --brightness 1.0 --pos 0x0 --rotate normal &
      slstatus &
      feh --bg-fill .background.png &
      picom &
      ibus-daemon -drxR
    '';
    displayManager.lightdm.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "yuzuki";
    };
    videoDrivers = [ "amdgpu" ];
  };

  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        patches =  [
          ./mydwm.patch
        ];
      });
    })

     (self: super: {
      slstatus = super.slstatus.overrideAttrs (oldAttrs: rec {
        patches =  [
          ./mystatus.patch
        ];
      });
    })
  ];

  xdg.portal.enable = true;

}
