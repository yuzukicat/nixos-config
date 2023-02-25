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
  ]);

in {
  home.packages = with pkgs; [
    # Console
    runzip scc bubblewrap difftastic # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual
    sops # Sops

    # GUI
    kolourpaint libreoffice okular # Files
    electrum electron-cash monero-gui # Cryptocurrency
    (prismlauncher.override { jdks = [ openjdk ]; }) /* steam <- enabled system-wide */ # Games
    tdesktop my.pkgs.nheko-fix # Messaging
    wf-recorder obs-studio # Recording

    # Dev
    cachix patchelf nixpkgs-review nix-update nix-output-monitor # Nix utils
    gcc ghc myPython # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive # sqlite
    cabal-install gnumake yarn binutils ruby_3_1 xclip
    bash-completion cling racket rustc cargo elixir github-cli

    # Configuration from https://github.com/sauricat/flakes.git/home/home.nix
    # system:
    trash-cli bc
    hyfetch

    # internet:
    aria2 element-desktop vlc /*syncplay*/

    # work:
    scribus gimp xournalpp krita calibre gwenview
    pdftag ocrmypdf poppler_utils
    goldendict zotero

    # non-oss:
    zoom-us obsidian
  ];

  programs.feh.enable = true;
}
