{
  lib,
  config,
  ...
}: {
  programs.home-manager.enable = true;

  imports = [
    ./modules/direnv.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/kitty.nix
    ./modules/lf.nix
    ./modules/mapping.nix
    ./modules/nano-home.nix
    ./modules/rust.nix
    ./modules/starship.nix
    ./modules/startx.nix
    ./modules/task.nix
    ./modules/tmux.nix
    ./modules/qutebrowser.nix
    ./modules/zathura.nix
    ./modules/ranger
  ];

  programs.zsh.loginExtra = ''
    if [[ -z $DISPLAY && "$(tty)" = /dev/tty1 ]] && type sway >/dev/null; then
      exec systemd-cat --identifier=sway sway
    fi
  '';

  # home.sessionVariables.GTK_USE_PORTAL = 1;

  home.file = let
    home = config.home.homeDirectory;
    link = path: config.lib.file.mkOutOfStoreSymlink "${home}/${path}";
    linkPersonal = path: link "storage/personal/${path}";
  in {
    # ".local/share/fcitx5/rime/sync".source = linkPersonal "rime-sync";
    # ".local/share/password-store".source = linkPersonal "password-store";
    ".local/share/task".source = linkPersonal "taskwarrior";
    ".ssh".source = linkPersonal "ssh";
    # ".emacs.d/init.el" = {
    #   source = ./modules/emacs/init.el;
    #   recursive = true;
    # };
    # ".emacs.d/shu-tex.el" = {
    #   source = ./modules/emacs/shu/shu-tex.el;
    #   recursive = true;
    # };
    # ".emacs.d/shu-langserver-lsp.el" = {
    #   source = ./modules/emacs/shu/shu-langserver-lsp.el;
    #   recursive = true;
    # };
    # ".emacs.d/shu-langserver-eglot.el" = {
    #   source = ./modules/emacs/shu/shu-langserver-eglot.el;
    #   recursive = true;
    # };
    # ".emacs.d/shu-c.el" = {
    #   source = ./modules/emacs/shu/shu-c.el;
    #   recursive = true;
    # };
    # ".local/share/password-store" = {
    #   source = ../nixos/blacksteel/password-store;
    #   recursive = true;
    # };
    ".emacs.d" = {
      source = ./modules/emacs;
      recursive = true;
    };
    ".oh-my-zsh/custom/themes/passion.zsh-theme" = {
      source = ./modules/omz/passion.zsh-theme;
      recursive = true;
    };
    ".local/share/konsole/Noir-Light-Konsole.colorscheme" = {
      source = ./modules/konsole/Noir-Light-Konsole.colorscheme;
      recursive = true;
    };
    ".local/share/konsole/Nix.profile" = {
      source = ./modules/konsole/Nix.profile;
      recursive = true;
    };
    ".config/discocss/custom.css" = {
      source = ./modules/discocss/custom.css;
      recursive = true;
    };
    ".vdirsyncer/config" = {
      source = ./modules/vdirsyncer/config;
      recursive = true;
    };
    ".config/khal/config" = {
      source = ./modules/khal/config;
      recursive = true;
    };
    ".authinfo.gpg" = {
      source = ./modules/authinfo/.authinfo.gpg;
      recursive = true;
    };
    ".mailcap" = {
      source = ./modules/wanderlust/.mailcap;
      recursive = true;
    };
    ".mailrc" = {
      source = ./modules/wanderlust/.mailrc;
      recursive = true;
    };
  };

  programs.gpg.homedir = "${config.home.homeDirectory}/storage/personal/gnupg";

  # config.xresources.properties."Xft.dpi" = 300;

  # Add to home managers dag to make sure the activation fails if emacs can't
  # parse the init files and nuke any temp dirs we don't need/want to stick
  # around if present.
  home.activation.freshEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    printf "home/blacksteel.nix: clean ~/.emacs.d\n" >&2
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG ~/.emacs.d/init.el ~/.emacs.d/init.elc ~/.emacs.d/elpa ~/.emacs.d/eln-cache
  '';

  home.stateVersion = "23.05";
}
