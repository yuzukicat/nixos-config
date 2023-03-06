{ inputs, pkgs, config, lib, host, ... }:
let
  emacsPackage = pkgs.emacsGitNativeComp;
  emacsPackageWithPkgs =
    pkgs.emacsWithPackagesFromUsePackage {
      config =
        let
          readRecursively = dir:
            builtins.concatStringsSep "\n"
              (lib.mapAttrsToList (name: value: if value == "regular"
                                                then builtins.readFile (dir + "/${name}")
                                                else (if value == "directory"
                                                      then readRecursively (dir + "/${name}")
                                                      else [ ]))
                                  (builtins.readDir dir));
        in readRecursively ./emacs;
      alwaysEnsure = true;
      package = emacsPackage;
      extraEmacsPackages = epkgs: [ ];
      override = epkgs: epkgs // (let
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
        # vterm = vterm-mouse-support;
        # multi-vterm = epkgs.melpaPackages.multi-vterm.overrideAttrs (old: {
        #   buildInputs = [ emacsPackage pkgs.texinfo vterm-mouse-support ];
        #   propagatedBuildInputs = lib.singleton vterm-mouse-support;
        #   propagatedUserEnvPkgs = lib.singleton vterm-mouse-support;
        # });
        toggle-one-window = epkgs.trivialBuild rec {
          pname = "toggle-one-window";
          ename = pname;
          version = "git";
          src = inputs.epkgs-toggle-one-window;
        };
        exwm-ns = epkgs.trivialBuild rec {
          pname = "exwm-ns";
          ename = pname;
          version = "git";
          src = inputs.epkgs-exwm-ns;
          patches = [ ./patch/exwm-ns.patch ];
        };
        ligature = epkgs.trivialBuild rec {
          pname = "ligature";
          ename = pname;
          version = "git";
          src = inputs.epkgs-ligature;
        };
      });
    };
  lspPackages = with pkgs; [
    rust-analyzer
    nil # rnix-lsp
    pyright
    haskell-language-server
    solargraph
    yaml-language-server
    clang-tools
    elixir_ls
    lua53Packages.digestif
  ];
in
rec {
  home.sessionVariables = exwmSessionVariables // {
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
