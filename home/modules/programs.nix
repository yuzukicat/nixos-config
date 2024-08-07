{
  lib,
  pkgs,
  my,
  ...
}: let
  myPython = pkgs.python312Full.withPackages (ps:
    with ps; [
      # aiohttp
      # numpy
      # pylint
      # pyyaml
      # requests
      # toml
      python-lsp-server
      pylsp-mypy
      pyls-isort
      # python-lsp-black
      pyls-memestra
      pylsp-rope
      python-lsp-ruff
    ]);
  lspPackages = with pkgs; [
    rust-analyzer
    nil # rnix-lsp
    pyright
    haskell-language-server
    solargraph
    clang-tools
    lua53Packages.digestif
    cmake-language-server
    kotlin-language-server
    pkgs.gopls
    pkgs.gotools
    protoc-gen-go
    protoc-gen-go-grpc
    protoc-gen-doc
    sqls
    oapi-codegen
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.eslint
    nodePackages.graphql-language-service-cli
    nodePackages.typescript-language-server
    nodePackages.unified-language-server
    nodePackages.yaml-language-server
    nodePackages.intelephense
    php81Packages.phpstan
  ];
  obs = pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vaapi
    ];
  };
in {
  home.packages = with pkgs;
  with libsForQt5;
  with plasma5;
  with kdeGear;
  with kdeFrameworks;
    [
      # Console
      runzip
      scc
      bubblewrap
      difftastic # Random stuff
      xsel
      # wl-clipboard
      beancount
      my.pkgs.double-entry-generator
      tealdeer
      man-pages # Manual

      # GUI
      kolourpaint
      libreoffice
      mpv # Files
      # electrum
      # electron-cash
      # monero-gui
      tdesktop # Messaging
      # wf-recorder
      obs # Recording

      # Dev
      cachix
      patchelf
      nixpkgs-review
      nix-update
      nix-output-monitor # Nix utils
      gcc
      ghc
      myPython # Compiler & interpreters
      gdb # Debugger
      sqlite-interactive
      dasel
      postgresql # sqlite
      # nosql-workbench
      cabal-install
      gnumake
      yarn
      binutils
      xclip
      bash-completion
      cling
      elixir
      gh
      nodejs
      nodePackages.npm-check-updates
      nodePackages.prisma
      nodePackages.pnpm
      prisma-engines
      openssl
      protobuf
      pkg-config
      bashInteractive
      # coursera-dl

      # Configuration from https://github.com/sauricat/flakes.git/home/home.nix
      # system:
      trash-cli
      hyfetch

      # internet:
      android-studio
      aria
      # element-desktop
      vlc
      /*
      syncplay
      */

      # work:
      scribus
      gwenview
      gimp
      krita
      calibre
      xournalpp
      pdftag
      ocrmypdf
      poppler_utils
      # goldendict
      zotero
      imagemagick

      # non-oss:
      # obsidian
      # (discord-ptb.override {
      #   withVencord = true;
      # })
      zoom-us
      # teams-for-linux
      my.pkgs.librime-lua
      # feishu
      my.pkgs.systemd-run-app
      linuxPackages.perf
      hyperfine
      isoimagewriter
      qbittorrent
      chromium
      gnuplot
      php83
      lyx
      cyberchef
    ]
    ++ lspPackages;

  programs.alacritty.settings.font.size = lib.mkForce 10;
  programs.autorandr.enable = true; # Automatically select a display configuration based on connected devices.
  programs.dircolors = {
    enable = true;
    enableFishIntegration = true;
  };
  # TODO: Finish porting emacs config over future me fix
  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithConfig;
  };
  programs.feh.enable = true;
  programs.go = {
    enable = true;
    package = pkgs.go_1_21;
    packages = {
      "golang.org/x/tools/gopls@latest" = pkgs.gopls;
      "golang.org/x/tools@latest" = pkgs.gotools;
      "google.golang.org/protobuf@latest" = pkgs.protoc-gen-go;
      "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest" = pkgs.protoc-gen-go-grpc;
      "github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-docc@latest" = pkgs.protoc-gen-doc;
      "github.com/lighttiger2505/sqls@latest" = pkgs.sqls;
      "github.com/deepmap/oapi-codegen/v2/cmd/oapi-codegen@latest" = pkgs.oapi-codegen;
    };
  };
  # programs.kitty = {
  #   enable = true;
  #   font = {
  #     package = pkgs.fira-code;
  #     name = "fira-code";
  #     # size = 10;
  #     size = 12 * config.wayland.dpi / 96;
  #   };
  #   settings = {
  #     scrollback_lines = 10000;
  #     enable_audio_bell = false;
  #     update_check_interval = 0;
  #   };
  #   extraConfig = ''
  #     background            #F6F2EE
  #     foreground            #7E3462
  #     cursor                #3D2B5A
  #     selection_background  #3E2B5A
  #     color0                #1e1e1e
  #     color8                #444b6a
  #     color1                #f7768e
  #     color9                #ff7a93
  #     color2                #69c05c
  #     color10               #9ece6a
  #     color3                #ffcc99
  #     color11               #ffbd49
  #     color4                #3a8fff
  #     color12               #66ccff
  #     color5                #9ea0dd
  #     color13               #c89bb9
  #     color6                #0aaeb3
  #     color14               #56b6c2
  #     color7                #bfc2da
  #     color15               #d2d7ff
  #     selection_foreground  #BAB5BF
  #   '';
  # };
  # https://github.com/nix-community/home-manager/blob/master/modules/accounts/email.nix
  accounts.email.accounts.yuzuki = {
    primary = true;
    address = "dawei.jiang@nowhere.co.jp";
    flavor = "gmail.com";
    realName = "Yuzuki";
    userName = "dawei.jiang@nowhere.co.jp";
    passwordCommand = "pass show app_password";
    offlineimap = {
      enable = true;
      extraConfig = {
        account = {
          synclabels = true;
        };
        local = {
          filename_use_mail_timestamp = true;
        };
        remote = {
          maxconnections = 1;
        };
      };
    };
    mu = {
      enable = true;
    };
  };
  programs.offlineimap = {
    enable = true;
    extraConfig = {
      general = {
        maxsyncaccounts = 1;
        ui = "blinkenlights";
      };
    };
  };
  programs.mu.enable = true;
  # install VS Code via Home Manager
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [
        bbenoist.nix
        ms-vscode.anycode
        editorconfig.editorconfig
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
        donjayamanne.githistory
        mhutchie.git-graph
        codezombiech.gitignore
        rust-lang.rust-analyzer
        golang.go
        zxh404.vscode-proto3
        oderwat.indent-rainbow
        # _2gua.rainbow-brackets
        shardulm94.trailing-spaces
        ms-python.vscode-pylance
        ms-python.python
        ms-python.isort
        ms-python.black-formatter
        njpwerner.autodocstring
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        mechatroner.rainbow-csv
        graphql.vscode-graphql
        irongeek.vscode-env
        prisma.prisma
        cweijan.vscode-database-client2
        yzhang.markdown-all-in-one
        bierner.markdown-checkbox
        bierner.markdown-mermaid
        davidanson.vscode-markdownlint
        bradlc.vscode-tailwindcss
        angular.ng-template
        gencer.html-slim-scss-css-class-completion
        styled-components.vscode-styled-components
        eg2.vscode-npm-script
        wix.vscode-import-cost
        firefox-devtools.vscode-firefox-debug
        jnoortheen.nix-ide
        kamadorueda.alejandra
        tamasfe.even-better-toml
        zainchen.json
        ms-vscode.cmake-tools
        timonwong.shellcheck
        foxundermoon.shell-format
        elixir-lsp.vscode-elixir-ls
        gruntfuggly.todo-tree
        pkief.material-icon-theme
        catppuccin.catppuccin-vsc
        bodil.file-browser
        christian-kohler.path-intellisense
        alexdima.copy-relative-path
        rioj7.commandonallfiles
        bierner.emojisense
        ms-vscode.hexeditor
        kddejong.vscode-cfn-lint
        streetsidesoftware.code-spell-checker
        bmewburn.vscode-intelephense-client
        devsense.phptools-vscode
        devsense.composer-php-vscode
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [];
  };
}
