# Forked from github.com/oxalica/nixos-config
# For the purpose of testing, to install nixos on clevo nh55vr workstation.
{ lib, config, pkgs, inputs, my, ... }:

{
  imports = [
    ./vm.nix

    ../modules/console-env.nix
    ../modules/device-fix.nix
    ../modules/kde-desktop
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.blacksteel);

  # Install a proprietary or unfree package
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = drv:
    lib.elem (lib.getName drv) [
      "steam"
      "steam-original"
      "steam-run"
    ];
  
  # To make it work on clevo nh55vr rtx-3070max-q
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Use QT Scaling
  services.xserver.desktopManager.plasma5.useQtScaling = true;


  # Boot.

  boot = {
    initrd = {
      systemd.enable = true;

      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" ];
      kernelModules = [ "amd_pstate" "nvme" ];

      luks.devices."luksroot" = {
        device = "/dev/disk/by-uuid/8e445c05-75cc-45c7-bebd-46a73cf50a74";
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
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
    resumeDevice = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";
    kernelParams = [
      "resume_offset=38868224"
      "intel_pstate=passive"
    ];

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

  # Questions.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/fbfe849d-2d2f-415f-88d3-65ded870e46b";
      fsType = "btrfs";
      options = [ "relatime" "compress=zstd:1" "subvol=@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/9C91-4441";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/var/swap/resume"; }
  ];

  # Hardware.

  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    # AMD Microcode
    cpu.amd.updateMicrocode = true;
    video.hidpi.enable = true;
    bluetooth.enable = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.
    enableRedistributableFirmware = true; # Required for WIFI.
    # To-do: GPU acceleration
    # opengl.extraPackages = with pkgs; [ intel-media-driver ]; # vaapi
  };
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    useXkbConfig = true;
  };
  # Network configration Refered from ../invar/configuration.nix
  networking = {
    hostName = "blacksteel";
    search = [ "lan." ];
    useNetworkd = true;
    useDHCP = lib.mkForce true; # PCIE device changes would cause name changes.
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
    firewall.logRefusedConnections = false;
  };
  systemd.network.wait-online = {
    anyInterface = true;
    timeout = 15;
  };

  # Time Zone
  time.timeZone = "Asia/Tokyo";

  # Users.

  sops.secrets.passwd.neededForUsers = true;
  programs.zsh.enable = true; # As shell.
  users = {
    mutableUsers = false;
    users."oxa" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.oxa.name;
      extraGroups = [ "wheel" "kvm" "adbusers" "libvirtd" "wireshark" ];
    };
    groups."oxa".gid = 1000;
  };
  home-manager.users."oxa" =
    import ../../home/blacksteel.nix;
  # Transmission user group
  users.groups."transmission".members = [ config.users.users.oxa.name ];

  # Services.

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

  # Service configration Refered from ../invar/configuration.nix
  services.xserver.xkbOptions = "ctrl:swapcaps";

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services = {
    openssh = {
      enable = true;
      # SSH configration Refered from ../invar/configuration.nix
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "yes";
      hostKeys = [
        {
          type = "rsa";
          path = "/var/ssh/ssh_host_rsa_key";
          bits = 4096;
        }
        {
          type = "ed25519";
          path = "/var/ssh/ssh_host_ed25519_key";
          rounds = 100;
        }
      ];
      # settings = {
      #   KbdInteractiveAuthentication = false;
      #   PasswordAuthentication = false;
      #   # Warning: Unsafe
      #   PermitRootLogin = "yes";
      # };
    };
    fstrim = {
      enable = true;
      interval = "Wed,Sat 02:00";
    };
    timesyncd.enable = true;
    earlyoom = {
      enable = true;
      # earlyoom configration Refered from ../invar/configuration.nix
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
      enableNotifications = true;
    };
    # transmission configration Refered from ../invar/configuration.nix
    transmission = {
      enable = true;
      home = "/home/transmission";
    };
    btrbk.instances.snapshot = {
      onCalendar = "*:00,30";
      settings = {
        timestamp_format = "long-iso";
        preserve_day_of_week = "monday";
        preserve_hour_of_day = "6";
        snapshot_preserve_min = "6h";
        volume."/" = {
          snapshot_dir = ".snapshots";
          subvolume."home/oxa".snapshot_preserve = "48h 7d";
          subvolume."home/oxa/storage".snapshot_preserve = "48h 7d 4w";
        };
      };
    };
  };

  # vm configration Refered from ../invar/configuration.nix
  # onBoot ignore
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
  };

  nix = {
    package = inputs.nix-dram.packages.${config.nixpkgs.system}.nix-dram;

    # To fix Error: experimental NIX feature 'nix-command' is disabled
    extraOptions = ''
      experimental-features = auto-allocate-uids
    '';

    settings = {
      default-flake = "flake:nixpkgs";
      environment = [ "SSH_AUTH_SOCK" ];

      experimental-features = [
        # Might be required in ISO
        "nix-command"
        "flakes"
        "repl-flake"
        "auto-allocate-uids"
        "cgroups"
      ];
      extra-experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];
      auto-allocate-uids = true;
      use-cgroups = true;
    };

    # buildMachines = [
    #   {
    #     hostName = "aluminum.lan.hexade.ca";
    #     maxJobs = 24;
    #     protocol = "ssh-ng";
    #     sshUser = "oxa";
    #     sshKey = "/etc/ssh/ssh_host_ed25519_key";
    #     system = "x86_64-linux";
    #     supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
    #   }
    # ];
  };

  # Global ssh settings. Also for remote builders.
  programs.ssh = {
    knownHosts = my.ssh.knownHosts;
    extraConfig = ''
      Include ${config.sops.secrets.ssh-hosts.path}
    '';
  };
  sops.secrets.ssh-hosts = {
    sopsFile = ../../secrets/ssh.yaml;
    mode = "0444";
  };

  programs.adb.enable = true;
  # adbusers usergroup Refered from ../invar/configuration.nix
  # Question: Can it fix the bus error info on boot??
  users.groups."adbusers".members = [ config.users.users.oxa.name ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };
  
  # environment.etc Refered from ../invar/configuration.nix
  environment.etc = {
    "machine-id".source = "/var/machine-id";
    "ssh/ssh_host_rsa_key".source = "/var/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "/var/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "/var/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "/var/ssh/ssh_host_ed25519_key.pub";
  };

  environment.systemPackages = with pkgs; [
    # systemPackages Refered from ../invar/configuration.nix && ../minimal-image
    neofetch
    radeontop
    solaar # Logitech devices control.
    ltunify
    virt-manager
  ];

  system.stateVersion = "22.11";
}
