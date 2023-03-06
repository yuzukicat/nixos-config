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
    extraPackages = epkgs: [ epkgs.emms epkgs.magit epkgs.use-package];
    overrides = epkgs: super: rec {
      # haskell-mode = epkgs.melpaPackages.haskell-mode;
      toggle-one-window = epkgs.trivialBuild rec {
        pname = "toggle-one-window";
        ename = pname;
        version = "git";
        src = inputs.epkgs-toggle-one-window;
      };
    };
  };
}