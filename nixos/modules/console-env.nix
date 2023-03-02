{ lib, pkgs, my, ... }:
{
  # Reduce the closure size.
  # fonts.fontconfig.enable = lib.mkDefault false;

  # Default:
  # - nano # Already have vim.
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = with pkgs; [ ];

  environment.systemPackages = with pkgs; [
    cntr nix-top # Nix helpers.
    procs ncdu swapview smartmontools pciutils usbutils # System info.
    curl git strace pv exa fd ripgrep lsof jq loop bc file rsync dnsutils my.pkgs.rawmv # Utilities.
    e2fsprogs compsize # Filesystems.
    gnupg age pwgen sops ssh-to-age # Crypto.
    libarchive zstd # Compression.

    my.pkgs.nixos-rebuild-shortcut
    tmuxPlugins.nord

    wget home-manager
  ];

  programs.less = {
    enable = true;
    lessopen = null;
  };
  environment.variables = let
    common = [
      "--RAW-CONTROL-CHARS" # Only allow colors.
      "--mouse"
      "--wheel-lines=5"
      "--LONG-PROMPT"
    ];
  in {
    PAGER = "less";
    # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
    LESS = lib.concatStringsSep " " common;
    SYSTEMD_LESS = lib.concatStringsSep " " (common ++ [
      "--quit-if-one-screen"
      "--chop-long-lines"
      "--no-init" # Keep content after quit.
    ]);
  };

  programs.autorandr.enable = true;

  # Don't stuck for searching missing commands.
  programs.command-not-found.enable = false;

  programs.iftop.enable = true;
  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.mtr.enable = true;
  programs.tmux.enable = true;

  # programs.nano.defaultEditor = true;

  # Some defaults, override "basics.nix"
  programs.gnupg.agent.pinentryFlavor = "qt";
  services.flatpak.enable = true;

  # To use VS Code under Wayland, set the environment variable NIXOS_OZONE_WL=1:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
