{ config, lib, pkgs, inputs, my, ... }:

let
  # Global target
  emacsGit = inputs.emacs-overlay.packages.${pkgs.system}.emacsGit;

  home = config.home.homeDirectory;

in {

{
  programs.emacs = {
    enable = true;
    package = emacsGit;
    extraConfig = ''
      (setq standard-indent 2)
    '';
    extraPackages = with pkgs; with emacsGit.emacsPackages; [
      emms
      magit
      use-package
      all-the-icons
      trivialBuild
    ];
    overrides =  {
      lambda-line = my.pkgs.lambda-line.nix {
        inherit (pkgs) fetchFromGitHub trivialBuild all-the-icons;
      };
    };
  };
}
