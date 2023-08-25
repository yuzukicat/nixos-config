{
  pkgs,
  my,
  ...
}: {
  imports = [./l10n.nix];

  environment.systemPackages = with pkgs;
  with libsForQt5;
  with plasma5;
  with kdeGear;
  with kdeFrameworks; [
    nordic
    catppuccin-kde
    zafiro-icons
    nordzy-icon-theme
    nordzy-cursor-theme
    aha # needed by kinfocenter for fwupd support
    plasma-browser-integration
    konsole
    oxygen
    (lib.getBin qttools) # Expose qdbus in PATH
    elisa
    gwenview
    okular
    print-manager
    my.pkgs.bismuth-fix-5-27
  ];

  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
    dconf.enable = true;
  };

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  services.xserver = {
    enable = true;
    layout = "us";
    upscaleDefaultCursor = false;
    # Configure keymap in X11.
    # xkbVariant = "altgr-intl"; # included xkbOption "eurosign:5"
    # xkbOptions = "caps:none"; # xkeyboard-config(7)

    displayManager = {
      sddm.enable = true;
      # defaultSession = "plasmawayland";
      autoLogin = {
        enable = true;
        user = "yuzuki";
      };
    };

    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
      # supportDDC = true;
      useQtScaling = true;
      kdeglobals.KDE.SingleClick = false;
    };

    # To make it work on clevo nh55vr rtx-3070max-q
    # videoDrivers = ["nvidia"];
    videoDrivers = ["amdgpu"];
    # https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/amd/default.nix
    # videoDrivers = ["modesetting"];
  };

  security.pam.services.sddm.enableKwallet = true;

  # HIP
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
    "L+    /opt/rocm/hipcc   -    -    -     -  ${pkgs.hipcc}"
  ];

  # OpenCL && amdvlk
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
    # amdvlk
  ];

  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  # Vulkan
  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };

  services.colord.enable = true;
}
