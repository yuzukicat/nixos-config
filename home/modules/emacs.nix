{ config, lib, pkgs, inputs, my, ... }:

let

  home = config.home.homeDirectory;

in {
  home.packages = with pkgs; with inputs.emacs-overlay.packages.${pkgs.system}; [

  ];
  programs.emacs = {
    enable = true;
    package = inputs.emacs-overlay.packages.${pkgs.system}.emacsGit;
    extraConfig = ''
      (setq standard-indent 2)
    '';
    extraPackages = [];
    overrides = {
      lambda-line = my.pkgs.lambda-line;
    };
  };
}