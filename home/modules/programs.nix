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
  emacsPackage = pkgs.emacsGitNativeComp;
  emacsPackageWithPkgs =
    pkgs.emacsWithPackagesFromUsePackage {
      config =
        let
          readRecursively = dir:
            builtins.concatStringsSep "\n"
              (lib.mapAttrsToList (name: value: if value == "regular"
                                                then builtins.readFile (dir + "/${name}")
                                                else (if value == "directory"
                                                      then readRecursively (dir + "/${name}")
                                                      else [ ]))
                                  (builtins.readDir dir));
        in readRecursively ./emacs;
      alwaysEnsure = true;
      package = emacsPackage;
      extraEmacsPackages = epkgs: [ ];
      override = epkgs: epkgs // ({
        tree-sitter-langs = epkgs.tree-sitter-langs.withPlugins
          # Install all tree sitter grammars available from nixpkgs
          (grammars: builtins.filter lib.isDerivation (lib.attrValues (grammars // {
            tree-sitter-nix = grammars.tree-sitter-nix.overrideAttrs (old: {
              version = "fixed";
              src = inputs.tree-sitter-nix-oxa;
            });
          })));
        toggle-one-window = epkgs.trivialBuild rec {
          pname = "toggle-one-window";
          ename = pname;
          version = "git";
          src = inputs.epkgs-toggle-one-window;
        };
        exwm-ns = epkgs.trivialBuild rec {
          pname = "exwm-ns";
          ename = pname;
          version = "git";
          src = inputs.epkgs-exwm-ns;
          patches = [ ./patch/exwm-ns.patch ];
        };
        ligature = epkgs.trivialBuild rec {
          pname = "ligature";
          ename = pname;
          version = "git";
          src = inputs.epkgs-ligature;
        };
      });
    };
  lspPackages = with pkgs; [
    rust-analyzer
    nil # rnix-lsp
    pyright
    haskell-language-server
    solargraph
    yaml-language-server
    clang-tools
    elixir_ls
    lua53Packages.digestif
  ];
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
    discocss #?discord with bug
    notmuch # email engine
  ];

  programs.alacritty.settings.font.size = lib.mkForce 10;
  programs.autorandr.enable = true; # Automatically select a display configuration based on connected devices.
  programs.dircolors.enable = true;
  programs.emacs = {
    enable = true;
    package = inputs.rust-overlay.packages.${pkgs.system}.emacsGit;
    extraConfig = let
      readRecursively = dir:
        builtins.concatStringsSep "\n"
          (lib.mapAttrsToList (name: value: if value == "regular"
                                            then builtins.readFile (dir + "/${name}")
                                            else (if value == "directory"
                                                  then readRecursively (dir + "/${name}")
                                                  else [ ]))
                              (builtins.readDir dir));
    in readRecursively ./emacs;
    extraPackages = epkgs: [ ];
    overrides = self: super: rec {
      tree-sitter-langs = self.tree-sitter-langs.withPlugins
        # Install all tree sitter grammars available from nixpkgs
        (grammars: builtins.filter lib.isDerivation (lib.attrValues (grammars // {
          tree-sitter-nix = grammars.tree-sitter-nix.overrideAttrs (old: {
            version = "fixed";
            src = inputs.tree-sitter-nix-oxa;
          });
        })));
      toggle-one-window = self.trivialBuild rec {
        pname = "toggle-one-window";
        ename = pname;
        version = "git";
        src = inputs.epkgs-toggle-one-window;
      };
      exwm-ns = self.trivialBuild rec {
        pname = "exwm-ns";
        ename = pname;
        version = "git";
        src = inputs.epkgs-exwm-ns;
        patches = [ ./patch/exwm-ns.patch ];
      };
      ligature = self.trivialBuild rec {
        pname = "ligature";
        ename = pname;
        version = "git";
        src = inputs.epkgs-ligature;
      };
    };
  };
  programs.feh.enable = true;
  programs.hyfetch.settings = {
    preset = "transgender";
    mode = "rgb";
    color_align = {
      mode = "horizontal";
    };
  };
  programs.lieer.enable = true; # ? cli mail
  services.mako.enable = true; # notification daemon for Wayland
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
