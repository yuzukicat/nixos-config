{pkgs, ...}: {
  imports = [../l10n.nix];

  programs = {
    thunar.enable = true;
    dconf.enable = true;
  };

  services.xserver = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
        dmenu
      ];
    };

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    displayManager = {
      lightdm.enable = true;
      defaultSession = "xfce+i3";
      autoLogin = {
        enable = true;
        user = "yuzuki";
      };
    };

    videoDrivers = ["modesetting"];

    dpi = 500;
  };

  services.gvfs.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.blueman.enable = true;

  # HIP
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}}"
    "L+    /opt/rocm/hipcc   -    -    -     -  ${pkgs.rocmPackages.hipcc}}"
  ];

  # OpenCL && amdvlk
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
    # amdvlk
  ];

  # hardware.opengl.extraPackages32 = with pkgs; [
  #   driversi686Linux.amdvlk
  # ];

  # Vulkan
  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };

  services.colord.enable = true;
}
