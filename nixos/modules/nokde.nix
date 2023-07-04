{
  config,
  pkgs,
  ...
}: {
  imports = [./l10n.nix];

  environment.systemPackages = with pkgs;
  with libsForQt5;
  with plasma5;
  with kdeGear;
  with kdeFrameworks; [
    nordic
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
    plasma5Packages.bismuth
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
    # videoDrivers = ["modesetting"];
  };

  security.pam.services.sddm.enableKwallet = true;

  # HIP
  # systemd.tmpfiles.rules = [
  #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  #   "L+    /opt/rocm/hipcc   -    -    -     -  ${pkgs.hipcc}"
  # ];

  # # # OpenCL && amdvlk
  # hardware.opengl.extraPackages = with pkgs; [
  #   rocm-opencl-icd
  #   rocm-opencl-runtime
  #   amdvlk
  # ];

  # Vulkan
  hardware.opengl.driSupport = true;

  services.colord.enable = true;
}
