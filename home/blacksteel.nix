{ lib, config, inputs, ... }:

{
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
    ./modules/helix
    ./modules/shell
  ];

  lib.homeManagerConfiguration = {
    extraModules = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
    ];
    configuration = import ./modules/plasma.nix;
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
  };

  programs.gpg.homedir = "${config.home.homeDirectory}/storage/personal/gnupg";

  home.stateVersion = "22.11";
}
