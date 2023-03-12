{ pkgs, my, ... }:
{
  i18n = {
    supportedLocales = [ "all" ]; # Override console-env.
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = "ja_JP.UTF-8";
    };
    inputMethod = {
      # enabled = "fcitx5";
      # fcitx5.addons = with pkgs; [ fcitx5-rime ];
      # fcitx5.enableRimeData = true;
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        typing-booster
        anthy
        rime
        uniemoji
        my.pkgs.librime-lua
      ];
    };
  };
  
  console = {
    font = "Lat2-Terminus16";
    # keyMap= "us";
    useXkbConfig = true;
  };

  # services.kmscon = {
  #   enable = true;
  #   extraConfig = "font-size=20";
  # };
}
