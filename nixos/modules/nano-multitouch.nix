{ ... }:

{
  services.xserver.libinput = {
    enable = true;
  };

  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  services.touchegg.enable = true;
}
