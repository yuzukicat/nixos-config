{lib, ...}: {
  # Network configration Refered from ../invar/configuration.nix
  networking = {
    hostName = "blacksteel";
    search = ["lan."];
    useNetworkd = true;
    useDHCP = lib.mkDefault true; # PCIE device changes would cause name changes.

    wireless = {
      enable = false; # Must be false for enabling networkmanager.
      userControlled.enable = true;
    };

    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
      ethernet.macAddress = "random";
      unmanaged = ["enp15s0"];
    };

    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
    firewall = {
      logRefusedConnections = false;
      checkReversePath = "loose";
    };

    # yuzuki
    interfaces = {
      docker0.useDHCP = lib.mkDefault true;
      enp15s0.useDHCP = lib.mkDefault true;
      wlp14s0.useDHCP = lib.mkDefault true;
    };

    # Work Station
    # interfaces = {
    #   enp4s0.useDHCP = lib.mkDefault true;
    #   wlp5s0.useDHCP = lib.mkDefault true;
    # };

    # 5950x
    # interfaces = {
    #   enp7s0.useDHCP = lib.mkDefault true;
    #   wlp6s0.useDHCP = lib.mkDefault true;
    #   tailscale0.useDHCP = lib.mkDefault true;
    # };
  };

  systemd.network.wait-online = {
    enable = false;
    anyInterface = true;
    timeout = 15;
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  # networking.proxy.default = if config.networking.hostName != "wlsn" then "http://127.0.0.1:7890" else "";
  # networking.proxy.allProxy = "http://127.0.0.1:7890";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # programs.proxychains = {
  #   enable = true;
  #   proxies.clash = {
  #     enable = true;
  #     type = "http";
  #     host = "127.0.0.1";
  #     port = 7890;
  #   };
  # };

  # services.zerotierone = {
  #   enable = true;
  #   joinNetworks = [ ];
  # };

  services.openssh = {
    enable = true;
    # SSH configration Refered from ../invar/configuration.nix
    # settings.PermitRootLogin = false;
    settings.KbdInteractiveAuthentication = false;
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
    # settings = {
    #   KbdInteractiveAuthentication = false;
    #   PasswordAuthentication = false;
    #   # Warning: Unsafe
    #   PermitRootLogin = "yes";
    # };
  };

  # programs.ssh = {
  #   extraConfig = ''
  #     Host Pod042A
  #         HostName 10.147.17.126
  #         User kuniklo
  #     Host *
  #         PubkeyAcceptedAlgorithms +ssh-rsa
  #         HostkeyAlgorithms +ssh-rsa
  #   '';
  # };

  # services.tailscale.enable = true;
}
