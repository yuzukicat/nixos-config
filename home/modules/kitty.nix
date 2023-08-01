{ pkgs
, config
, ...
}: {
  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.fira-code;
      name = "fira-code";
      # size = 10;
      size = 12 * config.wayland.dpi / 96;
    };
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      background_opacity = "0.95";
      confirm_os_window_close = "0";
    };

    shellIntegration.enableFishIntegration = true;

    # keybindings = {
    #   "cmd+t" = "new_tab";
    #   "cmd+j" = "next_tab";
    #   "cmd+k" = "previous_tab";
    #   "cmd+w" = "close_tab";
    # };

    extraConfig = ''
      shell ${pkgs.fish}/bin/fish -i
      disable_ligatures never
      cursor_blink_interval 0.3

      background            #F6F2EE
      foreground            #7E3462
      cursor                #3D2B5A
      selection_background  #3E2B5A
      color0                #1e1e1e
      color8                #444b6a
      color1                #f7768e
      color9                #ff7a93
      color2                #69c05c
      color10               #9ece6a
      color3                #ffcc99
      color11               #ffbd49
      color4                #3a8fff
      color12               #66ccff
      color5                #9ea0dd
      color13               #c89bb9
      color6                #0aaeb3
      color14               #56b6c2
      color7                #bfc2da
      color15               #d2d7ff
      selection_foreground  #BAB5BF

      protocol file
      ext js,jsx,ts,tsx,rs,c,cpp,cc,json,toml,kt,yaml,yml,sh,fish,nu,nix,lock
      action launch --type=overlay $EDITOR $FILE_PATH

      protocol file
      mime text/plain
      action launch --type=overlay $EDITOR $FILE_PATH

      # Open directories
      protocol file
      mime inode/directory
      action launch --cwd $FILE_PATH

      # Open executable file
      protocol file
      mime inode/executable,application/vnd.microsoft.portable-executable
      action launch --hold --type=overlay $FILE_PATH

      # Open text files without fragments in the editor
      protocol file
      mime text/*
      action launch --type=overlay $EDITOR $FILE_PATH

      # Open image files with icat
      protocol file
      mime image/*
      action launch --type=overlay kitty +kitten icat --hold $FILE_PATH

      # Open video files with vlc
      protocol file
      mime video/*
      action launch --type=os-window vlc $FILE_PATH

      # Open ssh URLs with ssh command
      protocol ssh
      action launch --type=overlay ssh $URL
    '';
  };
}
