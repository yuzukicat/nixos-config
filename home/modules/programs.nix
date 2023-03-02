{ lib, pkgs, my, ... }:

let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    aiohttp
    numpy
    pylint
    pyyaml
    requests
    toml
    epc
    pip
  ]);
  myCodeOSS = pkgs.vscode-with-extensions.vscode-extensions (ps: with ps;[
    ms-vscode.anycode
    golang.go
    prisma.prisma
    ms-toolsai.jupyter
    ms-python.python
    ms-pyright.pyright]);

in {
  home.packages = with pkgs; with libsForQt5; with plasma5; with kdeGear; with kdeFrameworks; [
    # Console
    runzip scc bubblewrap difftastic # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    kolourpaint libreoffice mpv okular # Files
    electrum electron-cash # Cryptocurrency
    tdesktop # Messaging
    wf-recorder obs-studio # Recording

    # Dev
    cachix patchelf nixpkgs-review nix-update nix-output-monitor # Nix utils
    gcc ghc myPython myCodeOSS# Compiler & interpreters
    gdb # Debugger
    sqlite-interactive sqls# sqlite
    cabal-install gnumake yarn binutils ruby_3_1 xclip
    bash-completion cling elixir gh
    go nodejs nodePackages.npm-check-updates

    # Configuration from https://github.com/sauricat/flakes.git/home/home.nix
    # system:
    trash-cli bc
    my.pkgs.hyfetch

    # internet:
    aria2 element-desktop vlc /*syncplay*/

    # work:
    scribus gwenview gimp krita calibre
    xournalpp pdftag ocrmypdf poppler_utils
    goldendict zotero

    # non-oss:
    zoom-us obsidian

    autorandr discocss exa feh lieer mako ncmpcpp notmuch
  ];

  programs.alacritty.settings.font.size = lib.mkForce 10;
  programs.autorandr.enable = true;
  programs.dircolors.enable = true;
  programs.exa.enable = true;
  programs.feh.enable = true;
  programs.hyfetch.settings = {
    preset = "transgender";
    mode = "rgb";
    color_align = {
      mode = "horizontal";
    };
  };
  programs.jq.enable = true;
}
