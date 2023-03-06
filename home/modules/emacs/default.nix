{ config, lib, pkgs, inputs, my, ... }:

let
  home = config.home.homeDirectory;
in {
  home.packages = with pkgs; with inputs.emacs-overlay.packages.${pkgs.system}; [
    (emacsWithPackagesFromUsePackage {
      package = emacsGit;  # replace with pkgs.emacsPgtk, or another version if desired.
      # config = path/to/your/config.el;
      # config = path/to/your/config.org; # Org-Babel configs also supported

      # Optionally provide extra packages not in the configuration file.
      extraEmacsPackages = epkgs: [
        epkgs.use-package;
      ];

      # Optionally override derivations.
      override = epkgs: epkgs // {
        # somePackage = epkgs.melpaPackages.somePackage.overrideAttrs(old: {
        #    # Apply fixes here
        # });
        lambda-line = my.pkgs.lambda-line.nix;
      };
    })
  ];

  programs.emacs = {
    enable = true;
    package = home.packages.emacsGit;
    extraConfig = ''
      (setq standard-indent 2)
    '';
    extraPackages = epkgs: [ epkgs.emms epkgs.magit epkgs.use-package ];
    overrides = self: super: rec {
      haskell-mode = self.melpaPackages.haskell-mode;
    };
  };
}
