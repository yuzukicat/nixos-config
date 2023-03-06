{ config, lib, pkgs, inputs, my, ... }:

{
  programs.emacs = {
    enable = true;
    package = inputs.emacs-overlay.packages.${pkgs.system}.emacsGit;
    extraConfig = ''
      (setq standard-indent 2)
    '';
    extraPackages = epkgs: [ epkgs.emms epkgs.magit epkgs.use-package ];
    overrides = self: super: rec {
      haskell-mode = self.melpaPackages.haskell-mode;
      lambda-line = my.pkgs.lambda-line.nix {
        inherit (pkgs) fetchFromGitHub;
        inherit (epkgs) trivialBuild all-the-icons;
      };
    };
  };
}
