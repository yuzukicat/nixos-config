{ lib, pkgs, my, inputs, ... }:

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
  plasma = inputs.plasma-manager.homeManagerModules.plasma-manager;
in {
  home.packages = with pkgs; with libsForQt5; with plasma5; with kdeGear; with kdeFrameworks; [
    # Console
    runzip scc bubblewrap difftastic # Random stuff
    xsel wl-clipboard # CLI-Desktop
    beancount my.pkgs.double-entry-generator # Accounting
    tealdeer man-pages # Manual

    # GUI
    kolourpaint libreoffice mpv # Files
    electrum electron-cash # Cryptocurrency
    tdesktop # Messaging
    wf-recorder obs-studio # Recording

    # Dev
    cachix patchelf nixpkgs-review nix-update nix-output-monitor # Nix utils
    gcc ghc myPython # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive sqls postgresql# sqlite
    cabal-install gnumake yarn binutils ruby_3_1 xclip
    bash-completion cling elixir gh
    go nodejs nodePackages.npm-check-updates

    # Configuration from https://github.com/sauricat/flakes.git/home/home.nix
    # system:
    trash-cli
    my.pkgs.hyfetch

    # internet:
    # aria2
    element-desktop vlc /*syncplay*/

    # work:
    scribus gwenview gimp krita calibre
    xournalpp pdftag ocrmypdf poppler_utils
    goldendict zotero

    # non-oss:
    zoom-us obsidian
    docker
    emacs
    discocss #?discord with bug
    notmuch # email engine
    plasma
  ];

  programs.alacritty.settings.font.size = lib.mkForce 10;
  programs.autorandr.enable = true; # Automatically select a display configuration based on connected devices.
  programs.dircolors.enable = true;
  programs.feh.enable = true;
  programs.plasma = {
    enable = true;

    # Some high-level settings:
    workspace.clickItemTo = "select";

    hotkeys.commands."Launch Konsole" = {
      key = "Meta+Alt+K";
      command = "konsole";
    };

    # Some mid-level settings:
    shortcuts = {
      ksmserver = {
        "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
      };

      kwin = {
        "Expose" = "Meta+,";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
      };
    };

    # A low-level setting:
    files."baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
  };
  programs.hyfetch.settings = {
    preset = "transgender";
    mode = "rgb";
    color_align = {
      mode = "horizontal";
    };
  };
  programs.lieer.enable = true; # ? cli mail
  programs.mako.enable = true; # notification daemon for Wayland
  programs.ncmpcpp.enable = true; # ? cli music management
  # install VS Code via Home Manager
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
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
    ]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [];
  };
}
