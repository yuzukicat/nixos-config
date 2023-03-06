{ config, lib, pkgs, inputs, my, ... }:

let

  home = config.home.homeDirectory;

in {
  home.packages = with pkgs; with inputs.emacs-overlay.packages.${pkgs.system}; [
    (emacs.override {
      package = emacsGit;
    })
  ];
}