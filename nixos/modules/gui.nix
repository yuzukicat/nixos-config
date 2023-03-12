{
  services.xserver = {
    enable = true;
    autorun = false;
    windowManager.dwm.enable = true;
    displayManager.startx.enable = true;
    videoDrivers = [ "nvidia" ];
  };

  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        patches =  [
          ./patch/mydwm.patch
        ];
      });
    })

     (self: super: {
      slstatus = super.slstatus.overrideAttrs (oldAttrs: rec {
        patches =  [
          ./patch/mystatus.patch
        ];
      });
    })
  ];

}