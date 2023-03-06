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
    ];
    overrides = self: super: rec {
      haskell-mode = self.melpaPackages.haskell-mode;
      lambda-line = with emacsPackages; [ my.pkgs.lambda-line.nix ];
    };
  };
}
