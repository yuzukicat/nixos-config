{ config, lib, pkgs, inputs, my, ... }:

let

  home = config.home.homeDirectory;

in {
  home.packages = with pkgs; with inputs.nix-doom-emacs.packages.${pkgs.system}; [
    (doom-emacs.override {
      doomPrivateDir = ./doom.d;
    })
  ];
}
