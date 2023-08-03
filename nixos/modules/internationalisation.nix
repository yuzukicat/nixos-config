{pkgs, ...}: {
  i18n = {
    supportedLocales = ["all"]; # Override console-env.
    defaultLocale = "en_CA.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = "ja_JP.UTF-8";
    };
    inputMethod = {
      # enabled = "fcitx5";
      # fcitx5.addons = with pkgs; [ fcitx5-rime ];
      # fcitx5.enableRimeData = true;
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-configtool ];
      # enabled = "ibus";
      # ibus.engines = with pkgs.ibus-engines; [
      #   typing-booster
      #   anthy
      #   rime
      #   uniemoji
      # ];
    };
  };

  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    # keyMap= "us";
    useXkbConfig = true;
  };

  # services.kmscon = {
  #   enable = true;
  #   extraConfig = "font-size=20";
  # };
}
