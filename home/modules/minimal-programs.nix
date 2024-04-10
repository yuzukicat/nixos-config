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
      diagrams
    ]);
  lspPackages = with pkgs; [
    rust-analyzer
    nil # rnix-lsp
    pyright
    pkgs.gopls
    pkgs.gotools
    protoc-gen-go
    protoc-gen-go-grpc
    protoc-gen-doc
    sqls
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.eslint
    nodePackages.graphql-language-service-cli
    nodePackages.typescript-language-server
    nodePackages.unified-language-server
    nodePackages.yaml-language-server
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
      bash-completion
      bashInteractive
      binutils
      cachix
      # cling
      coursera-dl
      dasel
      difftastic
      elixir
      gcc
      # gdb
      # ghc
      gh
      gnumake
      kolourpaint
      man-pages
      nix-output-monitor
      nix-update
      nmap
      nodejs
      nodePackages.npm-check-updates
      nodePackages.pnpm
      obs
      openssl
      patchelf
      pkg-config
      protobuf
      runzip
      scc
      sqlite-interactive
      tealdeer
      trash-cli
      vlc
      xclip
      yarn
      myPython

      calibre
      gwenview
      gimp
      imagemagick
      xournalpp
      pdftag
      ocrmypdf

      tdesktop
      zoom-us
      teams-for-linux
      linuxPackages.perf
      hyperfine
      my.pkgs.librime-lua
      my.pkgs.systemd-run-app
      isoimagewriter
      qbittorrent
      # chromium
      gnuplot
      okular
      xsel
      hyfetch
      lyx
      nodePackages.prisma
      prisma-engines
    ]
    ++ lspPackages;

  programs.autorandr.enable = true;

  programs.dircolors = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithConfig;
  };

  programs.feh.enable = true;

  programs.go = {
    enable = true;
    package = pkgs.go;
    packages = {
      "golang.org/x/tools/gopls@latest" = pkgs.gopls;
      "golang.org/x/tools@latest" = pkgs.gotools;
      "google.golang.org/protobuf@latest" = pkgs.protoc-gen-go;
      "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest" = pkgs.protoc-gen-go-grpc;
      "github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-docc@latest" = pkgs.protoc-gen-doc;
      "github.com/lighttiger2505/sqls@latest" = pkgs.sqls;
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
}
