{
  lib,
  pkgs,
  my,
  ...
}: {
  # Reduce the closure size.
  # fonts.fontconfig.enable = lib.mkDefault false;

  # Default:
  # - nano # Already have vim.
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = with pkgs; [nano];

  environment.systemPackages = with pkgs; [
    cntr
    procs # procs zsh
    gdu # Ncdu is a disk usage analyzer with an ncurses interface
    swapview
    smartmontools
    pciutils # lspci
    usbutils # System info.
    curl
    git
    strace
    pv # Monitoring of data being sent through pipe, including copying file.
    eza # exa --long --header --recurse
    fd
    ripgrep
    lsof
    jq
    loop
    bc
    file # Determine the type of a file and its data. Doesn't take the file extension into account, and runs a series of tests to discover the type of file data.
    rsync
    dnsutils # dig example.com MX +short; nslookup example.com
    e2fsprogs # For ext234.
    compsize # Filesystems.
    gnupg
    age
    pwgen # pwgen -c -n -s -v -B
    sops
    ssh-to-age # Crypto.
    libarchive
    zstd # Compression.

    my.pkgs.nixos-rebuild-shortcut
    tmuxPlugins.nord

    wget
    home-manager
    # nvfetcher
    poetry
    deno
    sdcv
    tree-sitter
    rocmPackages.clr
    rocmPackages.hip-common
    rocmPackages.hipcc
    # azure-cli
    discocss
    nuget-to-nix
    discordchatexporter-cli
    dotnet-sdk_8
    dotnet-runtime_8
    dotnet-aspnetcore_8
    dotnetPackages.Nuget
    gyb
    openai-whisper-cpp
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
    networkmanagerapplet
    nitrogen
    pasystray
    picom
    rofi
    gnome.gnome-keyring
    polkit_gnome
    pulseaudioFull
    aspell
    arandr
    bat
    btop # A monitor of resources
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
    lxappearance
    zafiro-icons
    catppuccin-gtk
    dunst
    libsForQt5.okular
    libsForQt5.ark
    flameshot
    amdgpu_top
    lact
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
    # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
    LESS = lib.concatStringsSep " " common;
    SYSTEMD_LESS = lib.concatStringsSep " " (common
      ++ [
        "--quit-if-one-screen"
        "--chop-long-lines"
        "--no-init" # Keep content after quit.
      ]);
  };

  # Don't stuck for searching missing commands.
  programs.adb.enable = true;
  programs.command-not-found.enable = false;

  programs.iftop.enable = true; # iftop -i wlp6s0
  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.mtr.enable = true; #mtr -4 example.com
  programs.tmux.enable = true;
  programs.zsh.enable = true;
  programs.kclock.enable = true;

  # programs.nano.defaultEditor = true;

  # Some defaults, override "basics.nix"
  # programs.gnupg.agent.pinentryFlavor = "qt";
  services.flatpak.enable = true; #  A framework for distributing desktop applications across various Linux distributions.
  # To use VS Code under Wayland, set the environment variable NIXOS_OZONE_WL=1:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # services.emacs = {
  #   enable = true;
  #   package = pkgs.emacsWithConfig; # replace with emacs-gtk, or a version provided by the community overlay if desired.
  #   client = {
  #     enable = true;
  #   };
  #   startWithUserSession = true;
  # };
  systemd.services."autovt@tty1".enable = false;
}
