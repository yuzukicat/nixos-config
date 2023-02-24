{ config, pkgs, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs.plasma5Packages; [
    ark
    filelight
    plasma-browser-integration
    bismuth
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
        user = "oxa";
      };
    };

    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;

      kdeglobals.KDE.SingleClick = false;
    };
  };

  security.pam.services.sddm.enableKwallet = true;

  # networking.networkmanager = {
  #   enable = true;
  #   wifi.macAddress = "random";
  #   ethernet.macAddress = "random";
  # };
  
  # system.activationScripts.installerDesktop = let

  #   # Comes from documentation.nix when xserver and nixos.enable are true.
  #   manualDesktopFile = "/run/current-system/sw/share/applications/nixos-manual.desktop";

  #   homeDir = "/home/nixos/";
  #   desktopDir = homeDir + "Desktop/";

  # in ''
  #   mkdir -p ${desktopDir}
  #   chown nixos ${homeDir} ${desktopDir}

  #   ln -sfT ${manualDesktopFile} ${desktopDir + "nixos-manual.desktop"}
  #   ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
  #   ln -sfT ${pkgs.konsole}/share/applications/org.kde.konsole.desktop ${desktopDir + "org.kde.konsole.desktop"}
  # '';
}
