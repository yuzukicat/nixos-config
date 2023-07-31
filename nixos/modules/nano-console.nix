{
  lib,
  pkgs,
  my,
  inputs,
  ...
}: {
  environment.defaultPackages = with pkgs; [nano];

  environment.systemPackages = with pkgs; [
    bc
    compsize # Filesystems
    curl
    dnsutils # dig example.com MX +short; nslookup example.com
    e2fsprogs # For ext234
    exa # exa --long --header --recurse
    fd
    file # Determine the type of a file and its data. Doesn't take the file extension into account, and runs a series of tests to discover the type of file data
    gdu # Ncdu is a disk usage analyzer with an ncurses interface
    git
    gnupg
    jq
    libarchive
    lsof
    pciutils # lspci
    procs # procs zsh
    pv # Monitoring of data being sent through pipe, including copying file
    pwgen # pwgen -c -n -s -v -B
    ripgrep
    rsync
    sdcv
    sops
    tree-sitter
    usbutils # System info
    zstd

    my.pkgs.nixos-rebuild-shortcut
    tmuxPlugins.nord

    wget
    home-manager
    hip
    hip-common
    hipcc
    discocss
    nuget-to-nix
    discordchatexporter-cli
    dotnet-sdk_8
    dotnet-runtime_8
    dotnet-aspnetcore_8
    dotnetPackages.Nuget
    gyb
    my.pkgs.openai-whisper-cpp
    clblast
    ffmpeg
    my.pkgs.cmdg
    lynx # text mode web browser
    gmailctl
    glow
    poppler # pdf
    poppler_utils
    djvulibre # img
    pandoc
    texlive.combined.scheme-full
    my.pkgs.browsh
    ddgr # duckduckgo
    khal
    vdirsyncer
    anystyle-cli
    cacert
    gnutls
    busybox
    texmacs # math edit
    cryptsetup
    fastpbkdf2
    drive
    yubikey-manager
    xray
    ryzenadj
    you-get
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

  programs.mtr.enable = true; #mtr -4 example.com

  programs.tmux.enable = true;

  programs.zsh.enable = true;

  services.flatpak.enable = true;

  systemd.services."autovt@tty1".enable = false;
}
