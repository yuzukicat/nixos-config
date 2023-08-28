# Forked from github.com/yuzukilica/nixos-config
# For the purpose of testing, to install nixos on clevo nh55vr workstation.
{ lib, config, pkgs, inputs, my, ... }:

{
  imports = [
    ../modules/bluetooth.nix
    ../modules/console-env.nix
    ../modules/desktop-server.nix
    ../modules/gui
    ../modules/internationalisation.nix
    ../modules/l10n.nix
    ../modules/multitouch.nix
    ../modules/network.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/systemd-unit-protections.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.invar);

  # Boot.
  boot = {
    # disable initrd
    initrd = {
      # systemd.enable = true;

      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod" "sdhci_pci" ];
      kernelModules = [ "dm-snapshot" ];

      luks.devices = {
        crypted = {
          device = "/dev/disk/by-partuuid/6f4a96b4-1390-da41-8ea6-642400b4dfdf";
          # header = "/dev/disk/by-partuuid/bb58c05e-d8ac-438e-a856-c4a17160557c";
          allowDiscards = true; # Used if primary device is a SSD
          preLVM = true;
        };
        crypted2 = {
          device = "/dev/disk/by-partuuid/caf49c69-6dad-49ea-81b6-04b6675b91f9";
          # header = "/dev/disk/by-partuuid/bb58c05e-d8ac-438e-a856-c4a17160557c";
          allowDiscards = true; # Used if primary device is a SSD
          preLVM = true;
        };

      };
    };
    # For MGLRU in Linux 6.1
    # https://github.com/NixOS/nixpkgs/pull/205269
    #
    # NB. Don't upgrate to 6.2 before the BTRFS bug gets fixed.
    # https://lore.kernel.org/linux-btrfs/CABXGCsNzVxo4iq-tJSGm_kO1UggHXgq6CdcHDL=z5FL4njYXSQ@mail.gmail.com
    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];

    # For hibernate-resume.
    # `sudo btrfs inspect-internal map-swapfile /var/swap/resume --resume-offset`
    # => 38868224
    # resumeDevice = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";
    # kernelParams = [
    #   "resume_offset=38868224"
    #   "intel_pstate=passive"
    # ];

    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max"; # Don't clip boot menu.
      };
      efi.canTouchEfiVariables = true;
      timeout = lib.mkForce 1;
    };

    kernel.sysctl = {
      # Refer to vm.nix
      "kernel.sysrq" = "1";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  systemd.packages = [ my.pkgs.keystat ];

  # Use nixos-generate-config --root /mnt then copy and paste
  # Questions.
  # Work Station
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/81168bfa-6973-48fb-bbfc-94d3a17e4231";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/81168bfa-6973-48fb-bbfc-94d3a17e4231";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AF84-4891";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/891953e4-1cc9-4a5d-b0ab-6423aaf216d5"; }
    ];

  # Hardware.
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.
    opengl.enable = true;
    # Vulkan
    opengl.driSupport = true;
  };
  services.colord.enable = true;

  # Time Zone
  time.timeZone = "Asia/Tokyo";

  programs.fish = {
    enable = true;
  };

  # Users.
  # sops.secrets.passwd.neededForUsers = true;
  users = {
    mutableUsers = true;
    users."yuzuki" = {
      isNormalUser = true;
      shell = pkgs.fish;
      # Allow the graphical user to login without password
      initialHashedPassword = "";
      # password = "yuzuki";
      # passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.yuzuki.name;
      extraGroups = [ "wheel" "kvm" "adbusers" "libvirtd" "wireshark" "video" "docker" "discocss" "networkmanager" "audio" "sound" "input"];
    };
    groups."yuzuki".gid = 1000;
    # Allow the user to log in as root without a password.
    users.root.initialHashedPassword = "";
  };
  home-manager.users."yuzuki" =
    import ../../home/invar.nix;
  # Transmission user group
  # users.groups."transmission".members = [ config.users.users.yuzuki.name ];

  # Services.
  # AMD Ryzen 5950x
  systemd.services.nix-daemon.serviceConfig = {
    CPUQuota = "1500%";
    CPUWeight = 50;

    MemoryMax = "52G";
    MemoryHigh = "48G";
    MemorySwapMax = "64G";
    IOWeight = 50;
  };
  # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
  systemd.services.keystat.wantedBy = [ "multi-user.target" ];

  # Moved to services code block
  # KDE pulls in pipewire via xdg-desktop-portal anyways.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true; # Better installed with pipewire.
  sound.enable = false; # pipewire expects this.
  # Might be necessary to solve the conflict with kde-plasma5 audio
  hardware.pulseaudio.enable = lib.mkForce false;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraConfig = "load-module module-switch-on-connect";
  hardware.acpilight.enable = true;

  services = {
    # If you have a ssd, don't forget to enable fstrim
    fstrim = {
      enable = true;
      interval = "Wed,Sat 02:00";
    };
    timesyncd.enable = true;
    # Avoid Linux locking up in low memory situations using earlyoom
    earlyoom = {
      enable = true;
      # earlyoom configration Refered from ../invar/configuration.nix
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
      enableNotifications = true;
    };
    # transmission configration Refered from ../invar/configuration.nix
    # transmission = {
    #   enable = true;
    #   home = "/home/transmission";
    # };
    btrbk.instances.snapshot = {
      onCalendar = "*:00,30";
      settings = {
        timestamp_format = "long-iso";
        preserve_day_of_week = "monday";
        preserve_hour_of_day = "6";
        snapshot_preserve_min = "6h";
        volume."/" = {
          snapshot_dir = ".snapshots";
          subvolume."home/yuzuki".snapshot_preserve = "48h 7d";
          subvolume."home/yuzuki/storage".snapshot_preserve = "48h 7d 4w";
        };
      };
    };
    fwupd.enable = true;
    udisks2.enable = true;
    udisks2.mountOnMedia = true;
    unclutter.enable = true;
  };

  # Global ssh settings. Also for remote builders.
  programs.ssh = {
    knownHosts = my.ssh.knownHosts;
    # extraConfig = ''
    #   Include ${config.sops.secrets.ssh-hosts.path}
    # '';
  };
  # sops.secrets.ssh-hosts = {
  #   sopsFile = ../../secrets/ssh.yaml;
  #   mode = "0444";
  # };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  # environment.etc Refered from ../invar/configuration.nix
  environment.etc = {
    "machine-id".source = "/var/machine-id";
    # "ssh/ssh_host_rsa_key".source = "/var/ssh/ssh_host_rsa_key";
    # "ssh/ssh_host_rsa_key.pub".source = "/var/ssh/ssh_host_rsa_key.pub";
    # "ssh/ssh_host_ed25519_key".source = "/var/ssh/ssh_host_ed25519_key";
    # "ssh/ssh_host_ed25519_key.pub".source = "/var/ssh/ssh_host_ed25519_key.pub";
  };

  environment.systemPackages = with pkgs; [
    # systemPackages Refered from ../invar/configuration.nix && ../minimal-image
    neofetch
    # radeontop
    solaar # Logitech devices control.
    ltunify
    virt-manager
    aspell
    arandr
    bat
    btop # A monitor of resources
    dmenu # dmenu is a fast and lightweight dynamic menu for X
    slstatus # slstatus is a status monitor for window managers that use WM_NAME or stdin to fill the status bar
    feh # feh is an X11 image viewer aimed mostly at console users
    gcc
    glow # Render markdown on the CLI, with pizzazz!
    gimp
    killall
    my.pkgs.hyfetch
    pamixer # pamixer is like amixer but for pulseaudio. It can control the volume levels of the sinks
    pavucontrol
    alsa-utils
    arandr
    picom
    ueberzugpp # w3m img
    input-utils
    xbindkeys
    ranger # file management
    slock
  ];

  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  system.stateVersion = "23.05";
}
