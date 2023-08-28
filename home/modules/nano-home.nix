{
  pkgs,
  my,
  ...
}: let
  myPython = pkgs.python311.withPackages (ps:
    with ps; [
      # aiohttp
      numpy
      pylint
      pyyaml
      requests
      toml
      # Required for lsp-bridge
      openai
      epc
      orjson
      sexpdata
      six
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
    my.pkgs.gotools
    # go-tools
    # protoc-gen-go
    # protoc-gen-doc
    # protoc-gen-go-grpc
    rnix-lsp
    sqls
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.eslint
    nodePackages.graphql-language-service-cli
    nodePackages.typescript-language-server
    nodePackages.unified-language-server
    nodePackages.yaml-language-server
  ];
in {
  home.packages = with pkgs;
    [
      # Console
      runzip
      scc
      bubblewrap
      difftastic # Random stuff
      xsel
      xclip
      trash-cli # CLI-Desktop
      my.pkgs.hyfetch
      tealdeer
      man-pages # Manual

      tdesktop

      # Dev
      cachix
      patchelf
      nix-update
      nix-output-monitor # Nix utils
      gcc
      ghc
      myPython # Compiler & interpreters
      gdb # Debugger
      sqlite-interactive
      sqls
      postgresql # sqlite
      cabal-install
      gnumake
      yarn
      binutils
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
      coursera-dl

      libreoffice

      # Configuration from https://github.com/sauricat/flakes.git/home/home.nix
      # Internet
      aria

      # autorandr direnv feh gpg lf nix-direnv qutebrowser password-store taskwarrior zathura iftop htop iotop mtr tmux

      # Work:
      calibre

      # non-oss:
      my.pkgs.librime-lua
      docker
      discord
      zoom-us
      my.pkgs.systemd-run-app
      google-chrome-dev
      isoimagewriter
      qbittorrent
      okular
      libsForQt5.kdeconnect-kde
    ]
    ++ lspPackages;

  programs.autorandr.enable = true; # Automatically select a display configuration based on connected devices.
  programs.dircolors.enable = true;
  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithConfig;
  };
  programs.feh.enable = true;
  programs.go = {
    enable = true;
    package = pkgs.go_1_20;
    packages = {
      "github.com/golang/tools/gopls@latest" = pkgs.gopls;
      # "github.com/lighttiger2505/sqls@latest" = pkgs.sqls;
      "go.googlesource.com/tools@latest" = my.pkgs.gotools;
      # "github.com/protocolbuffers/protobuf-go@latest"= pkgs.protoc-gen-go;
      # "github.com/grpc/grpc-go@latest" = pkgs.protoc-gen-go-grpc;
      # "github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest" = pkgs.protoc-gen-doc;
    };
  };
  programs.hyfetch = {
    package = my.pkgs.hyfetch;
    settings = {
      preset = "transgender";
      mode = "rgb";
      color_align = {
        mode = "horizontal";
      };
    };
  };

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
        matklad.rust-analyzer
        golang.go
        zxh404.vscode-proto3
        oderwat.indent-rainbow
        # _2gua.rainbow-brackets
        shardulm94.trailing-spaces
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
        cweijan.vscode-database-client2
        yzhang.markdown-all-in-one
        bierner.markdown-checkbox
        bierner.markdown-mermaid
        davidanson.vscode-markdownlint
        bradlc.vscode-tailwindcss
        angular.ng-template
        gencer.html-slim-scss-css-class-completion
        jpoissonnier.vscode-styled-components
        eg2.vscode-npm-script
        wix.vscode-import-cost
        firefox-devtools.vscode-firefox-debug
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
        christian-kohler.path-intellisense
        alexdima.copy-relative-path
        rioj7.commandOnAllFiles
        bierner.emojisense
        ms-vscode.hexeditor
        kddejong.vscode-cfn-lint
        streetsidesoftware.code-spell-checker
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [];
  };

  services.kdeconnet = {
    enable = true;
    indicator = true;
  };
}
