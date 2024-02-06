{
  services.xserver = {
    enable = true;
    autorun = true;
    windowManager.dwm.enable = true;
    displayManager.startx.enable = true;
    displayManager.defaultSession = "none+dwm";
    displayManager.sessionCommands = ''
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
    videoDrivers = [ "modesetting" ];
    dpi = 200;
    xkb.layout = "us";
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
