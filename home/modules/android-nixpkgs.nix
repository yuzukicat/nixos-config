{ config, ...}:
let
  android-sdk.enable = true;

  # Optional; default path is "~/.local/share/android".
  android-sdk.path = "${config.home.homeDirectory}/.android/sdk";

  android-sdk.packages = sdk: with sdk; [
    build-tools-31-0-0
    cmdline-tools-latest
    emulator
    platforms-android-31
    sources-android-31
  ];
in
{
  home.packages = [ android-sdk ];
}
