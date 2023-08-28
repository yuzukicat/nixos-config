{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    package = pkgs.firefox.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.zip pkgs.unzip ];

      # bash
      buildCommand = old.buildCommand + ''
        sed '/exec /i [[ "$XDG_SESSION_TYPE" == wayland ]] && export MOZ_ENABLE_WAYLAND=1' \
          --in-place "$out/bin/firefox"

        # Rebind C-W to C-S-W for closing tab.
        from1='<key id="key_close" data-l10n-id="close-shortcut" command="cmd_close" modifiers="accel" reserved="true"/>'
        tooo1='<key id="key_close" data-l10n-id="close-shortcut" command="cmd_close" modifiers="accel,shift" reserved="true"/>'
        from2='<key id="key_closeWindow" data-l10n-id="close-shortcut" command="cmd_closeWindow" modifiers="accel,shift" reserved="true"/>'
        tooo2='                                                                                                                     '
        file="$out/lib/firefox/browser/omni.ja"
        # The original file is a symlink.
        sed -E "s|$from1|$tooo1|; s|$from2|$tooo2|" "$file" >"$file.new"
        size1="$(stat -L -c '%s' "$file")"
        size2="$(stat -L -c '%s' "$file.new")"
        echo "$size1 $size2"
        [[ $size1 -eq $size2 ]]
        mv "$file.new" "$file"
      '';
    });

    profiles."main.profile" = {
      id = 0;
      isDefault = true;
      search.default = "DuckDuckGo";

      settings = {
        # Random config
        "browser.aboutConfig.showWarning" = false;
        "browser.search.region" = "CA";
        "browser.search.isUS" = false;
        "distribution.searchplugins.defaultLocale" = "en-CA";
        "general.useragent.locale" = "en-CA";

        # Theme.
        "devtools.theme" = "auto";
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "browser.display.use_system_colors" = true;

        # Let our font-config choose final fonts.
        # "font.language.group" = "zh-CN";

        # Hardware video decoding support.
        # See: https://wiki.archlinux.org/index.php/Firefox#Hardware_video_acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        # Enable user chrome, which is by default disabled.
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Site isolation.
        "fission.autostart" = true;

        # Configuration from https://github.com/sauricat/flakes.git/home/firefox.nix
        "browser.startup.page" = 3; # Always resume the previous browser session.

        "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw";

        "font.name.monospace.zh-CN" = "Sarasa Mono SC";
        "font.name.serif.zh-CN" = "Source Han Serif SC";
        "font.name.sans-serif.zh-CN" = "Source Han Sans SC";
        "font.name.cursive.zh-CN" = "AR PL UKai CN";

        "font.name.monospace.zh-HK" = "Sarasa Mono HC";
        "font.name.serif.zh-HK" = "Source Han Serif HC";
        "font.name.sans-serif.zh-HK" = "Source Han Sans HC";
        "font.name.cursive.zh-HK" = "AR PL UKai HK";

        "font.name.monospace.zh-TW" = "Sarasa Mono TC";
        "font.name.serif.zh-TW" = "Source Han Serif TC";
        "font.name.sans-serif.zh-TW" = "Source Han Sans TC";
        "font.name.cursive.zh-TW" = "AR PL UKai TW";

        "font.name.monospace.ja" = "Sarasa Mono J";
        "font.name.serif.ja" = "Source Han Serif";
        "font.name.sans-serif.ja" = "Source Han Sans";
        # "font.name.cursive.ja" = "";
      };

      # Hide tab
      userChrome = ''
        #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
          opacity: 0;
          pointer-events: none;
        }
        #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
          visibility: collapse !important;
        }
      '';
    };

    # For test.
    profiles."test.profile" = {
      id = 1;
      isDefault = false;
    };
  };

  # Host bridge for `pass` integration.
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  # https://bugzilla.mozilla.org/show_bug.cgi?id=1699942
  home.packages = [ pkgs.arc-theme ];
}
