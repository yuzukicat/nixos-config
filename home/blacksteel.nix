{
  lib,
  config,
  inputs,
  ...
}: {
  programs.home-manager.enable = true;

  imports = [
    ./modules/wayland-dpi.nix
    ./modules/alacritty.nix
    ./modules/direnv.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/lf.nix
    ./modules/mail.nix
    ./modules/mapping.nix
    ./modules/mime-apps.nix
    ./modules/programs.nix
    # ./modules/rime-fcitx.nix
    ./modules/rust.nix
    ./modules/task.nix
    ./modules/tmux.nix
    ./modules/user-dirs.nix
    ./modules/xdgify.nix
    ./modules/helix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/qutebrowser.nix
    # ./modules/compatibility.nix
    ./modules/kitty.nix
  ];

  lib.homeManagerConfiguration = {
    extraModules = [
      inputs.android-nixpkgs.hmModule
    ];
    configuration = import ./modules/android-nixpkgs.nix;
  };

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
    ".local/share/gyb".source = linkPersonal "gyb";
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
    ".emacs.d" = {
      source = ./modules/emacs;
      recursive = true;
    };
    # ".local/share/password-store" = {
    #   source = ../nixos/blacksteel/password-store;
    #   recursive = true;
    # };
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

  # Add to home managers dag to make sure the activation fails if emacs can't
  # parse the init files and nuke any temp dirs we don't need/want to stick
  # around if present.
  home.activation.freshEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    printf "home/blacksteel.nix: clean ~/.emacs.d\n" >&2
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG ~/.emacs.d/init.el ~/.emacs.d/init.elc ~/.emacs.d/elpa ~/.emacs.d/eln-cache
  '';

  # home.activation.freshWine = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   export WINEARCH=win64
  #   export WINEPREFIX=$HOME/.wine-battlenet
  # '';

  home.stateVersion = "23.05";
}
