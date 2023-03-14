{ lib, pkgs, my, inputs, ... }:

let
  myPython = pkgs.python3.withPackages (ps: with ps; [
    epc
    orjson
    sexpdata
    six
  ]);
  lspPackages = with pkgs; [
    rust-analyzer
    nodePackages.pyright
    gopls
    vscode-extensions.sumneko.lua
    nil # rnix-lsp
    nodePackages.typescript-language-server
    nodePackages.typescript
    nodePackages.bash-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.graphql-language-service-cli
    nodePackages.npm-check-updates
  ];
in {
  home.packages = with pkgs; [
    # Console
    runzip scc bubblewrap difftastic # Random stuff
    xsel xclip trash-cli # CLI-Desktop
    tealdeer man-pages # Manual

    # Dev
    cachix patchelf nix-update nix-output-monitor # Nix utils
    gcc ghc myPython # Compiler & interpreters
    gdb # Debugger
    sqlite-interactive sqls postgresql # sqlite
    cabal-install gnumake yarn binutils
    bash-completion cling elixir gh
    nodejs

    # Configuration from https://github.com/sauricat/flakes.git/home/home.nix
    # Internet
    aria

    autorandr feh

    # Work:
    scribus gwenview gimp krita calibre
    xournalpp pdftag ocrmypdf poppler_utils
    goldendict zotero

    # non-oss:
    zoom-us obsidian my.pkgs.librime-lua
    docker
  ]++ lspPackages;

  programs.alacritty.settings.font.size = lib.mkForce 10;
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
      "golang.org/x/tools/gopls@latest" = pkgs.gopls;
      "github.com/lighttiger2505/sqls@latest" = pkgs.sqls;
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
    ]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [];
  };
}
