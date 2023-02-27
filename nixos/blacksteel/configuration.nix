# Forked from github.com/yuzukilica/nixos-config
# For the purpose of testing, to install nixos on clevo nh55vr workstation.
{ lib, config, pkgs, inputs, my, ... }:

{
  imports = [
    # ./vm.nix

    ../modules/console-env.nix
    ../modules/device-fix.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/nokde.nix
    ../modules/internationalisation.nix
    ../modules/network.nix
    ../modules/bluetooth.nix
    ../modules/cups.nix
    ../modules/steam.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.blacksteel);

  # Boot.
  boot = {
    # disable initrd
    initrd = {
      # systemd.enable = true;

      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" "sdhci_pci"];
      kernelModules = [ "amd_pstate" "nvme" ];

    #   luks.devices."invar-luks" = {
    #     device = "/dev/disk/by-uuid/aa50ce23-65c4-4b9a-8484-641a06a9d08c";
    #     allowDiscards = true;
    #     crypttabExtraOpts = [ "fido2-device=auto" ];
    #   };
    };

    # For MGLRU in Linux 6.1
    # https://github.com/NixOS/nixpkgs/pull/205269
    #
    # NB. Don't upgrate to 6.2 before the BTRFS bug gets fixed.
    # https://lore.kernel.org/linux-btrfs/CABXGCsNzVxo4iq-tJSGm_kO1UggHXgq6CdcHDL=z5FL4njYXSQ@mail.gmail.com
    kernelPackages = pkgs.linuxPackages_6_1;

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

  # Use nixos-generate-config --root /mnt then copy and paste
  # Questions.
  # Work Station
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5fe2d576-ca83-41a1-a431-95b8374505ca";
      fsType = "btrfs";
      # zstd:1  W: ~510MiB/s
      # zstd:3  W: ~330MiB/s
      # options = [ "relatime" "compress=zstd:1" "subvol=@" "nofail"];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7B83-4C68";
      fsType = "vfat";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/413ae8ad-772e-48f8-b5b0-2468c20c5a66";
      fsType = "btrfs";
      # zstd:1  W: ~510MiB/s
      # zstd:3  W: ~330MiB/s
      # options = [ "relatime" "compress=zstd:1" "subvol=@" "nofail"];
    };
  };
  # 5950x PC
  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-uuid/cd16103a-da56-459e-ae5e-4d2e7041e973";
  #     fsType = "btrfs";
  #     # zstd:1  W: ~510MiB/s
  #     # zstd:3  W: ~330MiB/s
  #     # options = [ "relatime" "compress=zstd:1" "subvol=@" "nofail"];
  #   };

  #   "/boot" = {
  #     device = "/dev/disk/by-uuid/47E8-4FB6";
  #     fsType = "vfat";
  #   };

  #   "/home" = {
  #     device = "/dev/disk/by-uuid/4b4d1ff4-1cd0-4364-8975-99e57fa8d369";
  #     fsType = "btrfs";
  #     # zstd:1  W: ~510MiB/s
  #     # zstd:3  W: ~330MiB/s
  #     # options = [ "relatime" "compress=zstd:1" "subvol=@" "nofail"];
  #   };
  # };

  # swapDevices = [
  #   {
  #     device = "/var/swapfile";
  #     size = 32 * 1024; # 32G
  #   }
  # ];

  # Hardware.

  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    video.hidpi.enable = true;
    cpu.amd.updateMicrocode = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.
    # To-do: GPU acceleration
    # opengl.extraPackages = with pkgs; [ intel-media-driver ]; # vaapi
  };

  # Time Zone
  time.timeZone = "Asia/Tokyo";

  # Users.

  # sops.secrets.passwd.neededForUsers = true;
  programs.zsh.enable = true; # As shell.
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
      extraGroups = [ "wheel" "kvm" "adbusers" "libvirtd" "wireshark" "video" ];
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

  # AMD Ryzen 5800x
  systemd.services.nix-daemon.serviceConfig = {
    CPUQuota = "1500%";
    CPUWeight = 50;

    MemoryMax = "26G";
    MemoryHigh = "24G";
    MemorySwapMax = "32G";
    IOWeight = 50;
  };

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

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

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
  };

  systemd.packages = [ my.pkgs.keystat ];
  # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
  systemd.services.keystat.wantedBy = [ "multi-user.target" ];

  # vm configration Refered from ../invar/configuration.nix
  # onBoot ignore
  # virtualisation.libvirtd = {
  #   enable = true;
  #   onBoot = "ignore";
  # };

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
  users.groups."adbusers".members = [ config.users.users.yuzuki.name ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "Wed,Sat 01:00";
      options = "--delete-older-than 8d";
    };
    settings = {
      package = inputs.nix-dram.packages.${config.nixpkgs.system}.nix-dram;

      default-flake = "flake:nixpkgs";
      environment = [ "SSH_AUTH_SOCK" ];
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
  ];

  system.stateVersion = "22.11";
}
