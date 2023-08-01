{
  lib,
  config,
  ...
}: {
  programs.home-manager.enable = true;

  imports = [
    ./modules/direnv.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/lf.nix
    ./modules/mapping.nix
    ./modules/minimal-programmes.nix
    ./modules/rust.nix
    ./modules/tmux.nix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/startx.nix
    ./modules/user-dirs.nix
    ./modules/qutebrowser.nix
    ./modules/zathura.nix
    ./modules/ranger
  ];

  home.file = let
    home = config.home.homeDirectory;
    link = path: config.lib.file.mkOutOfStoreSymlink "${home}/${path}";
    linkPersonal = path: link "storage/personal/${path}";
  in {
    ".ssh".source = linkPersonal "ssh";
    ".emacs.d" = {
      source = ./modules/emacs;
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

  home.activation.freshEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    printf "home/blacksteel.nix: clean ~/.emacs.d\n" >&2
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG ~/.emacs.d/init.el ~/.emacs.d/init.elc ~/.emacs.d/elpa ~/.emacs.d/eln-cache
  '';

  home.stateVersion = "23.11";
}