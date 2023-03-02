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

    autorandr discocss exa feh lieer mako ncmpcpp notmuch vscode
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
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
        ms-vscode.anycode
        editorconfig.editorconfig
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
        donjayamanne.githistory
        mhutchie.git-graph
        codezombiech.gitignore
        matklad.rust-analyzer
        golang.go
        zxh404.vscode-proto3
        oderwat.indent-rainbow
        _2gua.rainbow-brackets
        shardulm94.trailing-spaces
        ms-python.python
        ms-python.vscode-pylance
        ms-pyright.pyright
        ms-python.vscode-pylance
        njpwerner.autodocstring
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        mechatroner.rainbow-csv
        graphql.vscode-graphql
        irongeek.vscode-env
        prisma.prisma
        yzhang.markdown-all-in-one
        bierner.markdown-checkbox
        bierner.markdown-mermaid
        bradlc.vscode-tailwindcss
        angular.ng-template
        kamikillerto.vscode-colorize
        eg2.vscode-npm-script
        wix.vscode-import-cost
        msjsdiag.debugger-for-chrome
        jnoortheen.nix-ide
        kamadorueda.alejandra
        bungcip.better-toml
        ms-vscode.cmake-tools
        timonwong.shellcheck
        foxundermoon.shell-format
        elixir-lsp.vscode-elixir-ls
        gruntfuggly.todo-tree
        pkief.material-icon-theme
        catppuccin.catppuccin-vsc
        bodil.file-browser
        alexdima.copy-relative-path
        rioj7.commandOnAllFiles
        bierner.emojisense
        ms-vscode.hexeditor
        kddejong.vscode-cfn-lint
    ];
    # ++ vscode-utils.extensionsFromVscodeMarketplace [
    #   {
    #     name = "code-runner";
    #     publisher = "formulahendry";
    #     version = "0.6.33";
    #     sha256 = "166ia73vrcl5c9hm4q1a73qdn56m0jc7flfsk5p5q41na9f10lb0";
    #   }
    # ];
  };
}
