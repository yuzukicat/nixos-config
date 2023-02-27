{ config, pkgs, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs.plasma5Packages; [
    ark
    filelight
    plasma-browser-integration
    bismuth
    gwenview
    okular
    spectacle
    nordic-colors
    kdeconnect-kde
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

    displayManager = {
      sddm.enable = true;
      # defaultSession = "plasmawayland";
      autoLogin = {
        enable = true;
        user = "nixos";
      };
    };

    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;

      kdeglobals.KDE.SingleClick = false;
    };
  };

  security.pam.services.sddm.enableKwallet = true;

  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    ethernet.macAddress = "random";
  };
  
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
