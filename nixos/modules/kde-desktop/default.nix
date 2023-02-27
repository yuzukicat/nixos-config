{ config, pkgs, lib, ... }:
{
  imports = [ ../l10n.nix ];

  environment.systemPackages = with pkgs; [
    ark
    filelight
    firefox
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

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+exwm";
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

    windowManager.session = lib.singleton {
      name = "exwm";
      start = pkgs.writeShellScript "start-exwm" ''
        if [[ -f $HOME/.xsessions/exwm.xsession ]]
        then
          exec ${pkgs.runtimeShell} -c $HOME/.xsessions/exwm.xsession
        else
          exit 1
        fi
      '';
    };
  };

  xdg.portal.enable = true;

  # Configure keymap in X11.
  services.xserver.xkbVariant = "altgr-intl"; # included xkbOption "eurosign:5"
  services.xserver.xkbOptions = "caps:none"; # xkeyboard-config(7)

  services.autorandr.enable = true;

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
