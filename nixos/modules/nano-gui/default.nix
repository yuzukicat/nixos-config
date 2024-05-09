{inputs, ...}:

{
  services.xserver = {
    enable = true;
    autorun = true;
    windowManager.dwm.enable = true;
    displayManager.startx.enable = true;
    displayManager.sessionCommands = ''
      slstatus &
      feh --bg-fill .background.png &
      picom &
      ibus-daemon -drxR
    '';
    displayManager.lightdm.enable = true;
    videoDrivers = [ "modesetting" ];
    dpi = 240;
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
