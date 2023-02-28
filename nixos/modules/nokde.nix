{ config, pkgs, ... }:
{
  imports = [ ./l10n.nix ];

  environment.systemPackages = with pkgs; [
    ark
    filelight
    gwenview
    kitty
    okular
    spectacle
    firefox
    nordic
    plasma-browser-integration
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
    # Configure keymap in X11.
    # xkbVariant = "altgr-intl"; # included xkbOption "eurosign:5"
    # xkbOptions = "caps:none"; # xkeyboard-config(7)

    displayManager = {
      sddm.enable = true;
      defaultSession = "plasmawayland";
      # autoLogin = {
      #   enable = true;
      #   user = "yuzuki";
      # };

      # sddm.theme = "nordic";
      # settings.Theme.CursorTheme = "Nordic-cursors";
      # settings.Theme.IconsTheme = "Zafiro-Nord-Black";
    };

    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
      kdeglobals.KDE.SingleClick = false;
      # Use QT Scaling?
      useQtScaling = true;
    };

    # To make it work on clevo nh55vr rtx-3070max-q
    videoDrivers = [ "nvidia" ];
  };

  xdg.portal.enable = true;

  services.autorandr.enable = true;

  security.pam.services.sddm.enableKwallet = true;
  
  # system.activationScripts.installerDesktop = let

  #   # Comes from documentation.nix when xserver and nixos.enable are true.
  #   # manualDesktopFile = "/run/current-system/sw/share/applications/nixos-manual.desktop";

  #   homeDir = "/home/yuzuki/";
  #   # transmissionDir = homeDir + "transmission/";
  #   desktopDir = homeDir + "Desktop/";
  #   storageDir = homeDir + "storage/";

  # in ''
  #   mkdir -p ${desktopDir}
  #   mkdir -p ${storageDir}
  #   chown yuzuki ${homeDir} ${desktopDir} ${storageDir}

  #   ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
  #   ln -sfT ${pkgs.konsole}/share/applications/org.kde.konsole.desktop ${desktopDir + "org.kde.konsole.desktop"}
  # '';
}
