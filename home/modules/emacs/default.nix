{ config, lib, pkgs, inputs, my, ... }:

{
  programs.emacs = {
    enable = true;
    package = inputs.emacs-overlay.packages.${pkgs.system}.emacsGit;
    extraConfig = ''
      (setq standard-indent 2)
    '';
    extraPackages = with emacsPackages; [
      emms
      magit
      use-package
      all-the-icons
    ];
    overrides = self: super: rec {
      haskell-mode = self.melpaPackages.haskell-mode;
      lambda-line = my.pkgs.lambda-line.nix;
    };
  };
}
