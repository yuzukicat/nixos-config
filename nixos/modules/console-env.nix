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

    emacs wget home-manager zsh-nix-shell vscode
    htop iotop iftop
    vscode-extensions.ms-vscode.anycode
    vscode-extensions.editorconfig.editorconfig
    vscode-extensions.esbenp.prettier-vscode
    vscode-extensions.dbaeumer.vscode-eslint
    vscode-extensions.donjayamanne.githistory
    vscode-extensions.mhutchie.git-graph
    vscode-extensions.codezombiech.gitignore
    vscode-extensions.matklad.rust-analyzer
    vscode-extensions.golang.go
    vscode-extensions.zxh404.vscode-proto3
    vscode-extensions.oderwat.indent-rainbow
    vscode-extensions._2gua.rainbow-brackets
    vscode-extensions.shardulm94.trailing-spaces
    vscode-extensions.ms-python.python
    vscode-extensions.ms-python.vscode-pylance
    vscode-extensions.ms-pyright.pyright
    vscode-extensions.ms-python.vscode-pylance
    vscode-extensions.njpwerner.autodocstring
    vscode-extensions.ms-toolsai.jupyter
    vscode-extensions.ms-toolsai.jupyter-keymap
    vscode-extensions.ms-toolsai.jupyter-renderers
    vscode-extensions.mechatroner.rainbow-csv
    vscode-extensions.graphql.vscode-graphql
    vscode-extensions.irongeek.vscode-env
    vscode-extensions.prisma.prisma
    vscode-extensions.yzhang.markdown-all-in-one
    vscode-extensions.bierner.markdown-checkbox
    vscode-extensions.bierner.markdown-mermaid
    vscode-extensions.bradlc.vscode-tailwindcss
    vscode-extensions.angular.ng-template
    vscode-extensions.kamikillerto.vscode-colorize
    vscode-extensions.eg2.vscode-npm-script
    vscode-extensions.wix.vscode-import-cost
    vscode-extensions.msjsdiag.debugger-for-chrome
    vscode-extensions.jnoortheen.nix-ide
    vscode-extensions.kamadorueda.alejandra
    vscode-extensions.bungcip.better-toml
    vscode-extensions.ms-vscode.cmake-tools
    vscode-extensions.timonwong.shellcheck
    vscode-extensions.foxundermoon.shell-format
    vscode-extensions.elixir-lsp.vscode-elixir-ls
    vscode-extensions.gruntfuggly.todo-tree
    vscode-extensions.pkief.material-icon-theme
    vscode-extensions.catppuccin.catppuccin-vsc
    vscode-extensions.bodil.file-browser
    vscode-extensions.alexdima.copy-relative-path
    vscode-extensions.rioj7.commandOnAllFiles
    vscode-extensions.bierner.emojisense
    vscode-extensions.ms-vscode.hexeditor
    vscode-extensions.kddejong.vscode-cfn-lint
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
