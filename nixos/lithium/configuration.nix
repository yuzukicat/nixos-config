# For the purpose of testing, to install nixos on asus rog ally.
{ lib, config, pkgs, inputs, my, ... }:

{
  imports = [
    ../modules/bluetooth.nix
    ../modules/nano-console.nix
    ../modules/cups.nix
    ../modules/desktop-server.nix
    ../modules/nano-gui
    ../modules/internationalisation.nix
    ../modules/l10n.nix
    ../modules/multitouch.nix
    ../modules/network.nix
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/systemd-unit-protections.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.invar);

  boot = {

    initrd = {

      systemd.enable = true;

      availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];

      kernelModules = ["dm-snapshot" "amdgpu"];

      luks.devices = {
        crypted = {
          device = "/dev/disk/by-partuuid/d93ac1c9-d525-482e-97dd-f5e078137e01";
          header = "/dev/disk/by-partuuid/6f4d3ed5-096d-4aff-beca-5335c3af172b";
          allowDiscards = true;
          bypassWorkqueues = true;
          preLVM = true;
          crypttabExtraOpts = ["fido2-device=auto" "x-initrd.attach"];
        };
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [ ];

    extraModulePackages = [ ];

    kernelParams = [
      "amd_pstate=active"
      # https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/raphael/igpu.nix
      "amdgpu.sg_display=0"
      # Try fixing nvme unavailability issue after S3 resume.
      # See: https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Controller_failure_due_to_broken_suspend_support
      "amd_iommu=fullflush"
      "pcie_aspm.policy=powersupersave"
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
      # Refer to vm.nix
      "kernel.sysrq" = "1";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  # Use nixos-generate-config --root /mnt then copy and paste
  # asus rog ally
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3151ca90-c0f6-4fed-b7fc-05a17b782c36";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/3151ca90-c0f6-4fed-b7fc-05a17b782c36";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A5E3-9BC6";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c06ebf0d-e6a1-4564-b125-38d6268ba3f7"; }
    ];

  # Hardware.
  powerManagement.cpuFreqGovernor = "performance";

  hardware = {

    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.

    opengl= {
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
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
    "L+    /opt/rocm/hipcc   -    -    -     -  ${pkgs.hipcc}"
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
      extraGroups = [ "wheel" "wireshark" "video" "discocss" "networkmanager" "audio" "sound" "input"];
    };
    groups."yuzuki".gid = 1000;
    # Allow the user to log in as root without a password.
    users.root.initialHashedPassword = "";
  };

  home-manager.users."yuzuki" =
    import ../../home/lithium.nix;

  # AMD Ryzen 7840U
  nix.settings.cores = 14;
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

    fwupd.enable = true;

    udisks2.enable = true;
    udisks2.mountOnMedia = true;

    unclutter.enable = true;

    asusd.enable = true;

    # fixes mic mute button
    udev.extraHwdb = ''
      evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
       KEYBOARD_KEY_ff31007c=f20
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
    asusctl
    aspell
    arandr
    bat
    btop # A monitor of resources
    dmenu # dmenu is a fast and lightweight dynamic menu for X
    slstatus # slstatus is a status monitor for window managers that use WM_NAME or stdin to fill the status bar
    feh # feh is an X11 image viewer aimed mostly at console users
    gcc
    killall
    my.pkgs.hyfetch
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
