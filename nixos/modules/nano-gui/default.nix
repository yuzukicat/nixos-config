{inputs, ...}:

{
  services.xserver = {
    enable = true;
    autorun = true;
    windowManager.dwm.enable = true;
    windowManager.dwm.package = inputs.nixpkgs-dwm-url.legacyPackages.dwm;
    displayManager.startx.enable = true;
    displayManager.sessionCommands = ''
      slstatus &
      feh --bg-fill .background.png &
      picom &
      ibus-daemon -drxR
    '';
    displayManager.lightdm.enable = true;
    videoDrivers = [ "modesetting" ];
    dpi = 200;
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
