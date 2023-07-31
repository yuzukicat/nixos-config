{ lib, pkgs, my, ... }:
{
  environment.systemPackages = [ my.pkgs.librime-lua];

  # Ref: https://catcat.cc/post/2021-03-07/
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      twemoji-color-font
      font-awesome
      hanazono
      emacs-all-the-icons-fonts # Required by emacs

      # CJKV
      noto-fonts-cjk
      hanazono
      source-han-sans source-han-serif source-han-mono
      wqy_microhei wqy_zenhei
      sarasa-gothic
      arphic-ukai arphic-uming
      unfonts-core
      # Use bin to save build time (~11min).
      (iosevka-bin.override { variant = "sgr-iosevka-fixed"; })
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        monospace = [ "Iosevka Fixed" "Noto Sans CJK SC" "Font Awesome 6 Free" "Twemoji" "Sarasa Mono SC"];
        # Prefer CJK-SC-style quotation marks.
        # We cannot select different styles for it based on languages since our locale is en_US.UTF-8.
        # See: https://catcat.cc/post/2021-03-07/#remark42__comment-37ccca1d-cbc6-4c48-a224-18007987cf16
        sansSerif = [ "Noto Sans" "Noto Sans CJK SC" "Twemoji" "Source Han Sans SC"];
        serif = [ "Noto Serif" "Noto Serif CJK SC" "Twemoji" "Source Han Serif SC"];
        emoji = [ "Twemoji" "Noto Emoji"];
      };

      localConf = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <!-- Use language-specific font variants. -->
          ${lib.concatMapStringsSep "\n" ({ lang, variant }:
            let
              replace = from: to: ''
                <match target="pattern">
                  <test name="lang" compare="contains">
                    <string>${lang}</string>
                  </test>
                  <test name="family">
                    <string>${from}</string>
                  </test>
                  <edit name="family" binding="strong" mode="prepend_first">
                    <string>${to}</string>
                  </edit>
                </match>
              '';
            in
            replace "sans-serif" "Noto Sans CJK ${variant}" +
            replace "serif" "Noto Serif CJK ${variant}"
          ) [
            { lang = "zh";    variant = "SC"; }
            { lang = "zh-TW"; variant = "TC"; }
            { lang = "zh-HK"; variant = "HK"; }
            { lang = "ja";    variant = "JP"; }
            { lang = "ko";    variant = "KR";  }
          ]}
        </fontconfig>
      '';
    };
  };
}
