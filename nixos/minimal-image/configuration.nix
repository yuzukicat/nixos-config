{ lib, config, pkgs, modulesPath, inputs, my, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-plasma5.nix")
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

  # Boot.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [ "kvm-amd" "amdgpu" ];
    # kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    # For amd dual monitor
    kernelParams = [
      # "video=card0-DP-1:2560x1440@60"
      # "video=card0-DP-2:2560x1440@60"
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

  # systemd.packages = [ my.pkgs.keystat ];

  # Hardware.
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
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
  users = {
    mutableUsers = true;
    users."nixos" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      # Allow the graphical user to login without password
      initialHashedPassword = "";
      # password = "nixos";
      # passwordFile = config.sops.secrets.passwd.path;
      uid = 1000;
      group = config.users.groups.nixos.name;
      extraGroups = [ "wheel" "kvm" "adbusers" "libvirtd" "wireshark" "video" ];
    };
    groups."nixos".gid = 1000;
    # Allow the user to log in as root without a password.
    users.root.initialHashedPassword = "";
  };
  home-manager.users."nixos" =
    import ../../home/minimal-iso.nix;
  # Transmission user group
  # users.groups."transmission".members = [ config.users.users.nixos.name ];

  # Services.
  # AMD Ryzen 7950x
  systemd.services.nix-daemon.serviceConfig = {
    CPUQuota = "3000%";
    CPUWeight = 50;

    MemoryMax = "52G";
    MemoryHigh = "48G";
    MemorySwapMax = "64G";
    IOWeight = 50;
  };
  # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
  # systemd.services.keystat.wantedBy = [ "multi-user.target" ];

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
    # btrbk.instances.snapshot = {
    #   onCalendar = "*:00,30";
    #   settings = {
    #     timestamp_format = "long-iso";
    #     preserve_day_of_week = "monday";
    #     preserve_hour_of_day = "6";
    #     snapshot_preserve_min = "6h";
    #     volume."/" = {
    #       snapshot_dir = ".snapshots";
    #       subvolume."home/nixos".snapshot_preserve = "48h 7d";
    #       subvolume."home/nixos/storage".snapshot_preserve = "48h 7d 4w";
    #     };
    #   };
    # };
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
  users.groups."adbusers".members = [ config.users.users.nixos.name ];

  # programs.wireshark = {
  #   enable = true;
  #   package = pkgs.wireshark-qt;
  # };

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
    radeontop
    solaar # Logitech devices control.
    ltunify
    virt-manager
  ];

  # Expend the disk size
  system.build.image = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    diskSize = 1024 * 128;
    installBootLoader = true;
    partitionTableType = "efi";
    inherit config lib pkgs;
  };

  system.stateVersion = "23.05";
}
