{ lib, pkgs, my, inputs, ... }:
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
    procs # procs zsh
    ncdu # Ncdu is a disk usage analyzer with an ncurses interface
    swapview smartmontools pciutils # lspci
    usbutils # System info.
    curl git strace pv # Monitoring of data being sent through pipe, including copying file.
    exa # exa --long --header --recurse
    fd ripgrep lsof jq loop bc file # Determine the type of a file and its data. Doesn't take the file extension into account, and runs a series of tests to discover the type of file data.
    rsync dnsutils # dig example.com MX +short; nslookup example.com
    my.pkgs.rawmv # Utilities.
    e2fsprogs # For ext234.
    compsize # Filesystems.
    gnupg age pwgen # pwgen -c -n -s -v -B
    sops ssh-to-age # Crypto.
    libarchive zstd # Compression.

    my.pkgs.nixos-rebuild-shortcut
    tmuxPlugins.nord

    wget home-manager

  ];

  programs.less = { # Dealing with a large text file page by page, resulting in fast loading speeds.
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

  # Don't stuck for searching missing commands.
  programs.command-not-found.enable = false;

  programs.iftop.enable = true; # iftop -i wlp6s0
  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.mtr.enable = true; #mtr -4 example.com
  programs.tmux.enable = true;

  # programs.nano.defaultEditor = true;

  # Some defaults, override "basics.nix"
  # programs.gnupg.agent.pinentryFlavor = "qt";
  services.flatpak.enable = true; #  A framework for distributing desktop applications across various Linux distributions.
  # To use VS Code under Wayland, set the environment variable NIXOS_OZONE_WL=1:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  services.emacs = {
    enable = true;
    package = pkgs.emacsWithConfig; # replace with emacs-gtk, or a version provided by the community overlay if desired.
  };
}
