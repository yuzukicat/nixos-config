{
  config,
  inputs,
  pkgs,
  ...
}: {
  # Install a proprietary or unfree package FOR nv, vscode
  nixpkgs.config.allowUnfree = true;
  #
  # nixpkgs.config.permittedInsecurePackages = with pkgs; [
  #     "qtwebkit-5.212.0-alpha4"
  #   ];

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  services.flatpak.enable = true;

  nix = {
    # package = inputs.nix-dram.packages.${config.nixpkgs.system}.nix-dram;

    # !! Warning: 2.19 currently fails to build this config !!
    # See: https://github.com/nix-community/home-manager/issues/4692
    package = assert builtins.compareVersions pkgs.nix.version "2.19" < 0; pkgs.nix;

    channel.enable = false;

    gc = {
      automatic = true;
      dates = "Wed,Sat 01:00";
      options = "--delete-older-than 8d";
    };

    settings = {
      # default-flake = "flake:nixpkgs";
      # environment = ["SSH_AUTH_SOCK"];
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
      ];

      auto-allocate-uids = true;
      use-cgroups = true;

      # FIXME: https://github.com/NixOS/nix/commit/a642b1030188f7538ef6243cd7fd1404419a6933
      # flake-registry =
      #   builtins.toFile "empty-registry.json"
      #   (builtins.toJSON {
      #     flakes = [];
      #     version = 2;
      #   });

      flake-registry = "";

      allow-import-from-derivation = false;
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];

      connect-timeout = 10;
      download-attempts = 3;
      stalled-download-timeout = 10;

      # Workaround: https://github.com/NixOS/nixpkgs/pull/273170
      nix-path = "nixpkgs=${inputs.nixpkgs}";
    };

    registry = {
      nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];

    # buildMachines = [
    #   {
    #     hostName = "aluminum.lan.hexade.ca";
    #     maxJobs = 24;
    #     protocol = "ssh-ng";
    #     sshUser = "yuzuki";
    #     sshKey = "/etc/ssh/ssh_host_ed25519_key";
    #     system = "x86_64-linux";
    #     supportedFeatures = [ "kvm" "big-parallel" "nixos-test" "benchmark" ];
    #   }
    # ];
  };
}
