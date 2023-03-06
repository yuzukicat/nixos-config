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
      (use-package toggle-one-window
        :bind ("C-c 1" . toggle-one-window))
    '';
    extraPackages = epkgs: [ epkgs.emms epkgs.magit epkgs.use-package ];
    overrides = self: super: rec {
      # haskell-mode = epkgs.melpaPackages.haskell-mode;
      toggle-one-window = self.trivialBuild rec {
        pname = "toggle-one-window";
        ename = pname;
        version = "git";
        src = inputs.epkgs-toggle-one-window;
      };
    };
  };
}