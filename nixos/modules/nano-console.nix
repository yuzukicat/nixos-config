{
  lib,
  pkgs,
  my,
  ...
}: {
  environment.defaultPackages = with pkgs; [nano];

  environment.systemPackages = with pkgs; [
    bc
    busybox
    cacert
    compsize # Filesystems
    cryptsetup
    curl
    ddgr # duckduckgo
    discocss
    discordchatexporter-cli
    dnsutils # dig example.com MX +short; nslookup example.com
    e2fsprogs # For ext234
    eza # exa --long --header --recurse
    fd
    ffmpeg
    file # Determine the type of a file and its data. Doesn't take the file extension into account, and runs a series of tests to discover the type of file data
    gdu # Ncdu is a disk usage analyzer with an ncurses interface
    git
    gnupg
    gnutls
    gyb
    rocmPackages.clr
    hipcc
    rocmPackages.hipcc
    home-manager
    jq
    khal
    libarchive
    lsof
    lynx # text mode web browser
    pciutils # lspci
    procs # procs zsh
    pv # Monitoring of data being sent through pipe, including copying file
    pwgen # pwgen -c -n -s -v -B
    ranger # file management
    ripgrep
    rsync
    sdcv
    sops
    tree-sitter
    usbutils # System info
    vdirsyncer
    wget
    xray
    you-get
    zstd

    my.pkgs.nixos-rebuild-shortcut
    my.pkgs.cmdg
    tmuxPlugins.nord
    texmacs # math edit
    glow
    poppler # pdf
    poppler_utils
    djvulibre # img
    gimp
    pandoc
    texlive.combined.scheme-full
    maim
  ];

  programs.less = {
    # Dealing with a large text file page by page, resulting in fast loading speeds.
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
    LESS = lib.concatStringsSep " " common;
    SYSTEMD_LESS = lib.concatStringsSep " " (common
      ++ [
        "--quit-if-one-screen"
        "--chop-long-lines"
        "--no-init"
      ]);
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.command-not-found.enable = false;

  programs.htop.enable = true;

  programs.iftop.enable = true; # iftop -i wlp6s0

  programs.iotop.enable = true;

  programs.kclock.enable = true;

  programs.kdeconnect.enable = true;

  programs.mtr.enable = true; #mtr -4 example.com

  programs.tmux.enable = true;

  programs.zsh.enable = true;

  services.flatpak.enable = true;

  systemd.services."autovt@tty1".enable = false;
}
