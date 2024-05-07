{
  services.xserver = {
    enable = true;
    autorun = true;
    windowManager.dwm.enable = true;
    displayManager.startx.enable = true;
    displayManager.sessionCommands = ''
      ryzenadj &
      xrandr --output DP-2 --primary --mode 3840x2160 --dpi 300 --brightness 1.0 --pos 0x0 --rotate normal --output HDMI-0 --same-as DP-2 --mode 3840x2160 --brightness 1.0 --rotate normal &
      slstatus &
      feh --bg-fill .background.png &
      picom &
      ibus-daemon -drxR
    '';
    displayManager.lightdm.enable = true;
    videoDrivers = [ "modesetting" ];
    dpi = 300;
    xkb.layout = "us";
  };

  services.displayManager.defaultSession = "none+dwm";

  services.displayManager.autoLogin = {
    enable = true;
    user = "yuzuki";
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
}
