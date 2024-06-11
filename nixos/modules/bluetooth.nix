{...}: {
  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  # services.blueman.enable = true;
  # services.dbus.packages = with pkgs; [
  #   bluez
  #   blueman
  # ];
  systemd.tmpfiles.rules = [
    # See https://github.com/NixOS/nixpkgs/issues/170573
    "d /var/lib/bluetooth 700 root root - -"
  ];
  systemd.targets."bluetooth".after = ["systemd-tmpfiles-setup.service"];
}
