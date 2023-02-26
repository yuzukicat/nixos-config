{ lib, config, pkgs, modulesPath, inputs, my, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-plasma5.nix")
    ../modules/console-env.nix
    ../modules/kde-desktop
    ../modules/nix-common.nix
    ../modules/nix-registry.nix
    ../modules/nix-binary-cache-mirror.nix
  ] ++ lib.optional (inputs ? secrets) (inputs.secrets.nixosModules.blacksteel);

  isoImage = {
    isoBaseName = "nixoxa";
    volumeID = "NIXOXA";
    # Worse compression but way faster.
    # squashfsCompression = "zstd -Xcompression-level 6";
    # Set this option to include all the needed sources etc in the image. It significantly increases image size. Use that when you want to be able to keep all the sources needed to build your
    # system or when you are going to install the system on a computer with slow or non-existent network connection.
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/iso-image.nix
    # [Segmentation fault when building ISO image with nixFlakes](https://github.com/NixOS/nix/issues/4246)
    # GC_DONT_GC=1 nix build ...
    includeSystemBuildDependencies = true;
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = with pkgs; [
      "qtwebkit-5.212.0-alpha4"
    ];

  nixpkgs.config.allowUnfreePredicate = drv:
    lib.elem (lib.getName drv) [
      "steam"
      "steam-original"
      "steam-run"
    ];

  services.xserver.desktopManager.plasma5.useQtScaling = true;
  # services.xserver.videoDrivers = [ "nvidia" ];

  # Boot.

  boot = {
     # Kernel >= 5.18 is required for `schedutil`.
    kernelPackages = pkgs.linuxPackages_6_1;
    kernelModules = [ "kvm-amd" ];

    # initrd = {
    #   systemd.enable = true;

    #   availableKernelModules = [ "xhci_pci" "ahci" "usbhid" ];
    #   kernelModules = [ "amd_pstate" "nvme" ];

    #   luks.devices."invar-luks" = {
    #     device = "/dev/disk/by-uuid/aa50ce23-65c4-4b9a-8484-641a06a9d08c";
    #     allowDiscards = true;
    #     crypttabExtraOpts = [ "fido2-device=auto" ];
    #   };
    # };

    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    loader = {
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "max"; # Don't clip boot menu.
      efi.canTouchEfiVariables = true;
      timeout = lib.mkForce 1;
    };

  };

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

  # Hardware.

  time.timeZone = "Asia/Tokyo";
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    video.hidpi.enable = true;
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true; # Solaar.
  };
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    useXkbConfig = true;
  };
  networking = {
    hostName = "nixoxa";
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

  # Users.

  # sops.secrets.passwd.neededForUsers = true;
  programs.zsh.enable = true; # As shell.
  users.mutableUsers = false;

  users.users."nixos" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    # passwordFile = config.sops.secrets.passwd.path;
    uid = 1000;
    group = config.users.groups.nixos.name;
    extraGroups = [ "wheel" "kvm" "adbusers" "libvirtd" "wireshark" "video" ];
  };
  users.groups."nixos".gid = 1000;
  home-manager.users."nixos" = import ../../home/blacksteel.nix;

  # Services.

  security.rtkit.enable = true; # Better installed with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  sound.enable = false; # pipewire expects this.
  hardware.pulseaudio.enable = lib.mkForce false;

  services.xserver.xkbOptions = "ctrl:swapcaps";

  services.timesyncd.enable = true;

  services.fstrim = {
    enable = true;
    interval = "Wed,Sat 02:00";
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "yes";
    # hostKeys = [
    #   {
    #     type = "rsa";
    #     path = "/var/ssh/ssh_host_rsa_key";
    #     bits = 4096;
    #   }
    #   {
    #     type = "ed25519";
    #     path = "/var/ssh/ssh_host_ed25519_key";
    #     rounds = 100;
    #   }
    # ];
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

  systemd.packages = [ my.pkgs.keystat ];
  # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
  systemd.services.keystat.wantedBy = [ "multi-user.target" ];

  nix = {
    package = inputs.nix-dram.packages.${config.nixpkgs.system}.nix-dram;

    settings = {
      default-flake = "flake:nixpkgs";
      environment = [ "SSH_AUTH_SOCK" ];

      experimental-features = [
        # Might be required in ISO
        "nix-command"
        "flakes"
        "repl-flake"
      ];
      extra-experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];
      auto-allocate-uids = true;
      use-cgroups = true;
    };
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
  users.groups."adbusers".members = [ config.users.users.nixos.name ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  environment.etc = {
    "machine-id".source = "/var/machine-id";
    # "ssh/ssh_host_rsa_key".source = "/var/ssh/ssh_host_rsa_key";
    # "ssh/ssh_host_rsa_key.pub".source = "/var/ssh/ssh_host_rsa_key.pub";
    # "ssh/ssh_host_ed25519_key".source = "/var/ssh/ssh_host_ed25519_key";
    # "ssh/ssh_host_ed25519_key.pub".source = "/var/ssh/ssh_host_ed25519_key.pub";
  };

  environment.systemPackages = with pkgs; [
    neofetch
    # radeontop
    solaar # Logitech devices control.
    ltunify
    virt-manager
  ];

  # Expend the disk size
  system.build.image = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    diskSize = 1024 * 64;
    installBootLoader = true;
    partitionTableType = "efi";
    inherit config lib pkgs;
  };

  system.stateVersion = "22.11";

}
