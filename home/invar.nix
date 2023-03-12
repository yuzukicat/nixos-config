{ lib, config, inputs, pkgs, my, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./modules/direnv.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/lf.nix
    # ./modules/mail.nix
    ./modules/mapping.nix
    # ./modules/mime-apps.nix
    ./modules/programs.nix
    # ./modules/rime-fcitx.nix
    ./modules/rust.nix
    ./modules/task.nix
    ./modules/tmux.nix
    # ./modules/user-dirs.nix
    # ./modules/xdgify.nix
    # ./modules/helix
    ./modules/shell
    ./modules/startx.nix
    ./modules/rime
    ./modules/qutebrowser.nix
    ./modules/zathura.nix
  ];

  programs.alacritty = {
    enable = true;
    package = my.pkgs.alacritty-fractional-scale;

    # https://github.com/alacritty/alacritty/blob/master/alacritty.yml
    settings = {
      import = [
        "${pkgs.vimPlugins.nightfox-nvim}/extra/dayfox/nightfox_alacritty.yml"
      ];

      window.padding = { x = 4; y = 0; };
      # window.startup_mode = "Fullscreen";
      window.startup_mode = "Maximized";

      scrolling.history = 1000; # Should not matter since we have tmux.
      scrolling.multiplier = 5;

      font.size = 12;
      # font.size = 12 * config.wayland.dpi / 96;

      # Set initial command on shortcuts, not for all alacritty.
      # shell.program = "${pkgs.tmux}/bin/tmux";

      mouse.hide_when_typing = true;
    };
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
    ".local/share/password-store".source = linkPersonal "password-store";
    ".local/share/task".source = linkPersonal "taskwarrior";
    ".ssh".source = linkPersonal "ssh";
    ".emacs.d/init.el" = {
      source = ./modules/emacs/init.el;
      recursive = true;
    };
    ".emacs.d/shu-tex.el" = {
      source = ./modules/emacs/shu/shu-tex.el;
      recursive = true;
    };
    ".emacs.d/shu-langserver-lsp.el" = {
      source = ./modules/emacs/shu/shu-langserver-lsp.el;
      recursive = true;
    };
    ".emacs.d/shu-langserver-eglot.el" = {
      source = ./modules/emacs/shu/shu-langserver-eglot.el;
      recursive = true;
    };
    ".emacs.d/shu-c.el" = {
      source = ./modules/emacs/shu/shu-c.el;
      recursive = true;
    };
    ".oh-my-zsh/custom/themes/passion.zsh-theme" = {
      source = ./modules/omz/passion.zsh-theme;
      recursive = true;
    };
  };

  programs.gpg.homedir = "${config.home.homeDirectory}/storage/personal/gnupg";

  # Add to home managers dag to make sure the activation fails if emacs can't
  # parse the init files and nuke any temp dirs we don't need/want to stick
  # around if present.
  home.activation.freshEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    printf "home/blacksteel.nix: clean ~/.emacs.d\n" >&2
    $DRY_RUN_CMD rm -rf $VERBOSE_ARG ~/.emacs.d/init.el ~/.emacs.d/init.elc ~/.emacs.d/elpa ~/.emacs.d/eln-cache
  '';

  home.stateVersion = "22.11";
}
