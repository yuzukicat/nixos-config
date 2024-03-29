{...}: {
  # services.avahi = {
  #   enable = true;
  #   nssmdns = true;
  # };

  services = {
    printing.enable = true;
    # drivers = [ pkgs.samsung-unified-linux-driver ];
    printing.cups-pdf.enable = true;

    avahi.enable = true;
    avahi.nssmdns4 = true;
    # for a WiFi printer
    avahi.openFirewall = true;
    # for an USB printer
    ipp-usb.enable = true;
  };

  # hardware.sane = {
  #   enable = true;
  #   extraBackends = with pkgs; [ sane-airscan ];
  #   # extraBackends = with pkgs; [ samsung-unified-linux-driver sane-airscan ];
  # };
  # services.saned.enable = true;
  # # environment.etc."sane.d/airscan.conf".text = ''
  # #   [devices]
  # #     Samsung C460 Series (SEC30CDA7AAB9A2) = http://192.168.2.100:8018/wsd/scan, WSD
  # # '';

  # environment.systemPackages = with pkgs; [ system-config-printer xsane simple-scan ];
}
