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
    overrides = epkgs: epkgs // (let
        vterm-mouse-support = epkgs.melpaPackages.vterm.overrideAttrs (old: {
          patches = (old.patches or [ ])
                    ++ [ ./patch/vterm-mouse-support.patch ];
        });
      in {
        tree-sitter-langs = epkgs.tree-sitter-langs.withPlugins
          # Install all tree sitter grammars available from nixpkgs
          (grammars: builtins.filter lib.isDerivation (lib.attrValues (grammars // {
            tree-sitter-nix = grammars.tree-sitter-nix.overrideAttrs (old: {
              version = "fixed";
              src = inputs.tree-sitter-nix-oxa;
            });
          })));
        toggle-one-window = epkgs.trivialBuild rec {
          pname = "toggle-one-window";
          ename = pname;
          version = "git";
          src = inputs.epkgs-toggle-one-window;
        };
      };
  };
}