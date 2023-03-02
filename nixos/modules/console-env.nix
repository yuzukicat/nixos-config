{ lib, pkgs, my, ... }:
{
  # Reduce the closure size.
  # fonts.fontconfig.enable = lib.mkDefault false;

  # Default:
  # - nano # Already have vim.
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = with pkgs; [ ];

  environment.systemPackages = with pkgs; [
    cntr nix-top # Nix helpers.
    procs ncdu swapview smartmontools pciutils usbutils # System info.
    curl git strace pv exa fd ripgrep lsof jq loop bc file rsync dnsutils my.pkgs.rawmv # Utilities.
    e2fsprogs compsize # Filesystems.
    gnupg age pwgen sops ssh-to-age # Crypto.
    libarchive zstd # Compression.

    my.pkgs.nixos-rebuild-shortcut
    tmuxPlugins.nord

    emacs wget home-manager zsh-nix-shell
    htop iotop iftop
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
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
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
      ];
    })
  ];

  programs.less = {
    enable = true;
    lessopen = null;
  };
  # Some defaults, override "basics.nix"
  programs.gnupg.agent.pinentryFlavor = lib.mkOverride 900 "qt";
  services.flatpak.enable             = lib.mkOverride 900 true;
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
    SYSTEMD_LESS = lib.concatStringsSep " " (common ++ [
      "--quit-if-one-screen"
      "--chop-long-lines"
      "--no-init" # Keep content after quit.
    ]);
  };

  programs.tmux.enable = true;

  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;

  programs.mtr.enable = true;

  # Don't stuck for searching missing commands.
  programs.command-not-found.enable = false;

  # programs.nano.defaultEditor = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
