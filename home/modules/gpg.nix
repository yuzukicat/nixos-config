{ config, pkgs, my, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      default-key = my.gpg.fingerprint;
      personal-cipher-preferences = "AES256 AES192 AES TWOFISH";
      personal-digest-preferences = "SHA512 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 Uncompressed";
      keyserver = "hkps://keys.openpgp.org";
    };
    scdaemonSettings = {
      deny-admin = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;

    pinentryPackage =
      if config.wayland.windowManager.sway.enable
        then "gtk2"
        else "qt";
    defaultCacheTtl = 600; # Default
    maxCacheTtl = 1800; # Default
    extraConfig = ''
  allow-emacs-pinentry
  allow-loopback-pinentry
    '';
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (ps: [ ps.pass-otp ]);
  };
}
