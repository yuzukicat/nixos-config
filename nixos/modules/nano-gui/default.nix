{
  services.xserver = {
    enable = true;
    autorun = true;
    windowManager.dwm.enable = true;
    displayManager.startx.enable = true;
    displayManager.defaultSession = "none+dwm";
    displayManager.sessionCommands = ''
      xrandr --output eDP --primary --mode 2560x1600 --dpi 200 --brightness 1.0 --pos 0x0 --rotate normal &
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
    dpi = 200;
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
