# Forked from github.com/yuzukilica/nixos-config
# For the purpose of testing, to install nixos on clevo nh55vr workstation.
{
  lib,
  config,
  pkgs,
  inputs,
  my,
  ...
}: {
  imports =
    [
      # ./vm.nix

      ../modules/bluetooth.nix
      ../modules/console-env.nix
      ../modules/cups.nix
      ../modules/desktop-server.nix
      ../modules/docker.nix
      ../modules/internationalisation.nix
      ../modules/multitouch.nix
      ../modules/network.nix
      ../modules/nix-common.nix
      ../modules/nix-registry.nix
      ../modules/nokde.nix
      ../modules/steam.nix
      ../modules/virtualisation.nix
      ../modules/systemd-unit-protections.nix
      # ../modules/nvdia.nix
    ]
    ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.blacksteel);

  # Boot.
  boot = {
    # disable initrd
    initrd = {
      # systemd.enable = true;

      availableKernelModules = ["thunderbolt" "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
      kernelModules = ["dm-snapshot" "amdgpu"];

      luks.devices."nixos-enc" = {
        device = "/dev/disk/by-partuuid/4c0e7158-2062-5141-8dae-15e7086a6be0";
        # header = "/dev/disk/by-partuuid/e9cea87e-7ba4-1c4d-bd74-98ea4d5c6d58";
        allowDiscards = true; # Used if primary device is a SSD
        preLVM = true;
        crypttabExtraOpts = ["fido2-device=auto" "no-read-workqueue" "no-write-workqueue"];
      };
    };
    # bootspec.enable = true;
    # For MGLRU in Linux 6.1
    # https://github.com/NixOS/nixpkgs/pull/205269
    #
    # NB. Don't upgrate to 6.2 before the BTRFS bug gets fixed.
    # https://lore.kernel.org/linux-btrfs/CABXGCsNzVxo4iq-tJSGm_kO1UggHXgq6CdcHDL=z5FL4njYXSQ@mail.gmail.com
    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    # For amd dual monitor
    kernelParams = [
      # "video=card0-DP-1:2560x1440@60"
      # "video=card0-DP-2:2560x1440@60"
      # "amd_pstate=passive"
      "amd_pstate=active"
      # https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/raphael/igpu.nix
      "amdgpu.sg_display=0"
      "amd_iommu=fullflush"
    ];

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

  systemd.packages = [my.pkgs.keystat];

  # Yuzucat
  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-uuid/f4209ec3-f651-4017-8732-9a201b7b48ba";
  #     fsType = "btrfs";
  #     # zstd:1  W: ~510MiB/s
  #     # zstd:3  W: ~330MiB/s
  #     # options = [ "noatime" "compress=zstd:1" "subvol=@" "nofail"];
  #   };

  #   "/boot" = {
  #     device = "/dev/disk/by-uuid/0D59-C632";
  #     fsType = "vfat";
  #   };

  #   "/home" = {
  #     device = "/dev/disk/by-uuid/c91e8302-9950-4d9c-afd2-5a340c1c86de";
  #     fsType = "btrfs";
  #     # zstd:1  W: ~510MiB/s
  #     # zstd:3  W: ~330MiB/s
  #     # options = [ "noatime" "compress=zstd:1" "subvol=@" ];
  #   };
  # };
  # 5950x PC
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ff4690c7-fe91-4b5f-87b0-c97c2ec12efb";
    fsType = "btrfs";
    options = ["subvol=root"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ff4690c7-fe91-4b5f-87b0-c97c2ec12efb";
    fsType = "btrfs";
    options = ["subvol=home"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/38E0-B0D8";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/c5ee32f2-d282-4a5e-b199-a1e3c57910d6";}
  ];

  # Hardware.
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.
    # To-do: GPU acceleration
    # opengl.extraPackages = with pkgs; [ intel-media-driver ]; # vaapi
  };

  # Time Zone
  time.timeZone = "Asia/Tokyo";

  # Users.
  # sops.secrets.passwd.neededForUsers = true;
  users = {
    mutableUsers = true;
    users."yuzuki" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      # Allow the graphical user to login without password
      initialHashedPassword = "";
      # password = "yuzuki";
      # passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.yuzuki.name;
      extraGroups = ["wheel" "kvm" "adbusers" "libvirtd" "wireshark" "video" "docker" "discocss"];
    };
    groups."yuzuki".gid = 1000;
    # Allow the user to log in as root without a password.
    users.root.initialHashedPassword = "";
  };
  home-manager.users."yuzuki" =
    import ../../home/blacksteel.nix;
  # Transmission user group
  # users.groups."transmission".members = [ config.users.users.yuzuki.name ];

  # Services.
  # AMD Ryzen 5950x
  systemd.services.nix-daemon.serviceConfig = {
    CPUQuota = "3000%";
    CPUWeight = 50;

    MemoryMax = "52G";
    MemoryHigh = "48G";
    MemorySwapMax = "64G";
    IOWeight = 50;
  };
  # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
  systemd.services.keystat.wantedBy = ["multi-user.target"];
  systemd.services.timer.wantedBy = ["multi-user.target"];

  # Moved to services code block
  # KDE pulls in pipewire via xdg-desktop-portal anyways.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
  security.rtkit.enable = true; # Better installed with pipewire.
  sound.enable = false; # pipewire expects this.
  # Might be necessary to solve the conflict with kde-plasma5 audio
  hardware.pulseaudio.enable = lib.mkForce false;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraConfig = "load-module module-switch-on-connect";

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

  programs.adb.enable = true;
  # adbusers usergroup Refered from ../invar/configuration.nix
  # Question: Can it fix the bus error info on boot??
  users.groups."adbusers".members = [config.users.users.yuzuki.name];

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

  # Need an usb sticker to maintaince?
  # environment.etc.crypttab = {
  #   enable = true;
  #   text = ''
  #     cryptroot /dev/nvme0n1p2 - fido2-device=auto
  #   '';
  # };

  environment.systemPackages = with pkgs; [
    # systemPackages Refered from ../invar/configuration.nix && ../minimal-image
    neofetch
    radeontop
    solaar # Logitech devices control.
    ltunify
    virt-manager
  ];

  system.stateVersion = "23.05";
}
