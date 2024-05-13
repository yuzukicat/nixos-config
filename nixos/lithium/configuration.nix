# For the purpose of testing, to install nixos on asus rog ally.
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
      ../modules/bluetooth.nix
      ../modules/nano-console.nix
      ../modules/cups.nix
      ../modules/desktop-server.nix
      ../modules/docker.nix
      ../modules/nano-gui
      ../modules/internationalisation.nix
      ../modules/l10n.nix
      ../modules/multitouch.nix
      ../modules/network.nix
      ../modules/nix-common.nix
      ../modules/nix-registry.nix
      ../modules/steam.nix
      ../modules/systemd-unit-protections.nix
      ../modules/virtualisation.nix
    ]
    ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.invar);

  boot = {
    initrd = {
      systemd.enable = true;

      availableKernelModules = ["xhci_pci" "nvme" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];

      kernelModules = ["dm-snapshot" "amdgpu"];

      luks.devices = {
        crypted = {
          device = "/dev/disk/by-partuuid/1219fe2c-2607-4875-a1e5-6df76d1bbeb7";
          header = "/dev/disk/by-partuuid/abd4ad50-bf21-4d49-84a3-881c095991df";
          allowDiscards = true;
          bypassWorkqueues = true;
          preLVM = true;
          # crypttabExtraOpts = ["fido2-device=auto" "x-initrd.attach"];
        };
      };
    };

    # kernelPackages = pkgs.linuxPackages_latest;

    kernelPackages =
        pkgs.linuxPackages_zen;

    kernelModules = [];

    extraModulePackages = [];

    kernelParams = [
      "amdgpu.sg_display=0"
    ];

    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = lib.mkForce 1;
    };

    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "kernel.sysrq" = "1";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv6.conf.default.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  # Use nixos-generate-config --root /mnt then copy and paste
  # asus rog ally
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/80416034-f229-4caf-b898-be748c80089d";
    fsType = "btrfs";
    options = ["subvol=root"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/80416034-f229-4caf-b898-be748c80089d";
    fsType = "btrfs";
    options = ["subvol=home"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/80416034-f229-4caf-b898-be748c80089d";
    fsType = "btrfs";
    options = ["subvol=nix"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6FA6-B2BC";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/dcc87f03-898c-47ee-af27-7b9c3f9c3558";}
  ];

  # Hardware.
  powerManagement.cpuFreqGovernor = "powersave";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.

    opengl = {
      enable = true;

      # Vulkan
      driSupport = true;
      driSupport32Bit = true;

      # OpenCL && amdvlk
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
    };
  };

  # HIP
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    "L+    /opt/rocm/hipcc   -    -    -     -  ${pkgs.rocmPackages.hipcc}"
  ];

  # services.colord.enable = true;

  time.timeZone = "Asia/Tokyo";

  programs.fish = {
    enable = true;
  };

  users = {
    mutableUsers = true;
    users."yuzuki" = {
      isNormalUser = true;
      shell = pkgs.fish;
      initialHashedPassword = "";
      uid = 1000;
      group = config.users.groups.yuzuki.name;
      extraGroups = ["wheel" "wireshark" "video" "discocss" "networkmanager" "audio" "sound" "input" "docker"];
    };
    groups."yuzuki".gid = 1000;
    # Allow the user to log in as root without a password.
    users.root.initialHashedPassword = "";
  };

  home-manager.users."yuzuki" =
    import ../../home/lithium.nix;

  # AMD Ryzen 7840U
  nix.settings.cores = 12;
  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 30;
    IOWeight = 30;
    MemoryMax = "12G";
    MemoryHigh = "10G";
    MemorySwapMax = "4G";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  security.rtkit.enable = true;
  sound.enable = false;
  hardware.pulseaudio.enable = lib.mkForce false;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraConfig = "load-module module-switch-on-connect";

  services = {
    fstrim = {
      enable = true;
      interval = "Wed,Sat 02:00";
    };

    timesyncd.enable = true;

    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
      enableNotifications = true;
    };

    # fwupd.enable = true;

    udisks2.enable = true;
    udisks2.mountOnMedia = true;

    unclutter.enable = true;

    btrfs.autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
      interval = "monthly";
    };

    udev.packages = [ my.pkgs.ublk-allow-unprivileged ];

    # asusd.enable = true;

    # # fixes mic mute button
    # udev.extraHwdb = ''
    #   evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
    #    KEYBOARD_KEY_ff31007c=f20
    # '';

    # fix suspend problem: https://www.reddit.com/r/gpdwin/comments/16veksm/win_max_2_2023_linux_experience_suspend_problems/
    udev.extraRules = ''
      ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x1022" ATTR{device}=="0x14ee" ATTR{power/wakeup}="disabled"
      SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="1", RUN+="${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=28000 --fast-limit=35000 --slow-limit=32000"
      SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="0", RUN+="${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=22000 --fast-limit=24000 --slow-limit=22000"
    '';
  };

  # Global ssh settings. Also for remote builders.
  programs.ssh = {
    knownHosts = my.ssh.knownHosts;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  environment.etc = {
    "machine-id".source = "/var/machine-id";
  };

  environment.systemPackages = with pkgs; [
    radeontop
    solaar # Logitech devices control.
    ltunify
    virt-manager
    # asusctl
    aspell
    arandr
    bat
    btop # A monitor of resources
    dmenu # dmenu is a fast and lightweight dynamic menu for X
    slstatus # slstatus is a status monitor for window managers that use WM_NAME or stdin to fill the status bar
    feh # feh is an X11 image viewer aimed mostly at console users
    gcc
    killall
    brightnessctl
    pamixer # pamixer is like amixer but for pulseaudio. It can control the volume levels of the sinks
    pavucontrol
    alsa-utils
    picom
    ueberzugpp # w3m img
    input-utils
    xbindkeys
    slock
  ];

  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  system.stateVersion = "23.11";
}
