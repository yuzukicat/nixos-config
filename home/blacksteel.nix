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

  lib.homeManagerConfiguration.extraModules = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  # programs.plasma = {
  #   enable = true;

  #   # Some high-level settings:
  #   workspace.clickItemTo = "select";

  #   hotkeys.commands."Launch Konsole" = {
  #     key = "Meta+Alt+K";
  #     command = "konsole";
  #   };

  #   # Some mid-level settings:
  #   shortcuts = {
  #     ksmserver = {
  #       "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
  #     };

  #     kwin = {
  #       "Expose" = "Meta+,";
  #       "Switch Window Down" = "Meta+J";
  #       "Switch Window Left" = "Meta+H";
  #       "Switch Window Right" = "Meta+L";
  #       "Switch Window Up" = "Meta+K";
  #     };
  #   };

  #   # A low-level setting:
  #   files."baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
  # };

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
