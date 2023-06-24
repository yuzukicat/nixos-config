{ lib, pkgs, config, ... }:
{
  assertions = [
    {
      assertion =
        config.programs.firefox.enable &&
        config.programs.feh.enable &&
        config.programs.alacritty.enable;
      message = "firefox, feh, and alacrittysy are used in MIME apps";
    }
  ];

  home.packages = with pkgs; [
    handlr
    (lib.hiPrio (pkgs.writeShellScriptBin "xdg-open" ''
      exec ${handlr}/bin/handlr open "$@"
    ''))
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Configuration from https://github.com/sauricat/flakes.git/home/home.nix
      "application/pdf" = "org.kde.okular.desktop";
      "image/*" = "org.kde.gwenview.desktop";
      "video/*" = "vlc.desktop";
      #
      "application/xhtml+xml" = "firefox.desktop";
      "text/*" = "emacs.desktop";
      "text/html" = "firefox.desktop";
      "text/mhtml" = "firefox.desktop";
      "text/xml" = "firefox.desktop";
      "x-scheme-handler/ftp" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/terminal" = "alacritty.desktop";
    };
  };
}
