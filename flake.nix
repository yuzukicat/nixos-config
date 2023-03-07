{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-plasma-5-27.url = "github:NixOS/nixpkgs/pull/211767/head";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unmatched.url = "github:oxalica/nixpkgs/test/unmatched";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    emacs-upstream = {
      url = "github:yuzukicat/emacs/master";
      flake = false;
    };
    nocargo = {
      url = "github:oxalica/nocargo";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    nix-dram = {
      url = "github:dramforever/nix-dram";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tree-sitter-nix-oxa = {
      url = "github:oxalica/tree-sitter-nix";
      flake = false;
    };

    epkgs-ligature = {
      url = "github:mickeynp/ligature.el";
      flake = false;
    };
    epkgs-toggle-one-window = {
      url = "github:manateelazycat/toggle-one-window";
      flake = false;
    };

    lsp-nil = {
      url = "github:oxalica/nil";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    meta-sifive = {
      url = "github:sifive/meta-sifive/2021.11.00";
      flake = false;
    };

    # Optional.
    # secrets.url = "/home/oxa/storage/repo/nixos-config-secrets";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: let

    inherit (nixpkgs) lib;

    overlays = [];

    nixosModules = {
      # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
      system-label = {
        system.configurationRevision = self.rev or null;
        system.nixos.label =
          if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
          then "${lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
          else lib.warn "Repo is dirty, revision will not be available in system label" "dirty";
      };

      home-manager = { config, inputs, my, ... }: {
        imports = [ inputs.home-manager.nixosModules.home-manager ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          verbose = true;
          extraSpecialArgs = {
            inherit inputs my;
            super = config;
          };
        };
      };

      emacs-overlay = { config, inputs, ... }: {
        nixpkgs.overlays = [
          inputs.emacs-overlay.overlay
          (final: prev: {
            emacs29 = prev.emacsGit.overrideAttrs (old: {
              name = "emacs29";
              version = inputs.emacs-upstream.shortRev;
              src = inputs.emacs-upstream;
            });
            # TODO: figure out a way to import based on this...
            # sys = pkgs.lib.last (pkgs.lib.splitString "-" pkgs.system);
            emacsWithConfig = (prev.emacsWithPackagesFromUsePackage {
              # config = builtins.readFile "../../static/emacs/init.org";
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
                in readRecursively ./home/modules/emacs;
              # config = ./home/modules/emacs/init.el;
              alwaysEnsure = true;
              package = final.emacs29;
              # Force these two even though they're outside of the org config.
              extraEmacsPackages = epkgs: [
                epkgs.use-package
                epkgs.org
                epkgs.cmake-mode
                epkgs.ligature
                epkgs.diminish
                epkgs.winum
                epkgs.ivy
                epkgs.counsel
                epkgs.swiper
                epkgs.flycheck
                epkgs.doom-themes
                epkgs.nix-mode
                epkgs.markdown-mode
                epkgs.yaml-mode
                epkgs.fish-mode
                epkgs.rust-mode
                epkgs.elixir-mode
                epkgs.cargo
                epkgs.dired-single
                epkgs.dirvish
                epkgs.pdf-tools
                epkgs.tree-sitter-langs
                epkgs.undo-tree
                epkgs.mwim
                epkgs.good-scroll
                epkgs.dashboard
                epkgs.magit
                epkgs.hydra
                epkgs.use-package-hydra
                epkgs.multiple-cursors
                epkgs.lsp-mode
                epkgs.lsp-ivy
                epkgs.lsp-ui
                epkgs.projectile
                epkgs.counsel-projectile
                epkgs.treemacs
                epkgs.treemacs-projectile
                epkgs.treemacs-icons-dired
                epkgs.treemacs-tab-bar
                epkgs.lsp-treemacs
                epkgs.company
                epkgs.company-box
                epkgs.yasnippet
                epkgs.yasnippet-snippets
                epkgs.go-mode
              ];
              override = epkgs: epkgs // {
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
                ligature = epkgs.trivialBuild rec {
                  pname = "ligature";
                  ename = pname;
                  version = "git";
                  src = inputs.epkgs-ligature;
                };
              };
            });
          })
        ];
      };

      sops = { config, ... }: {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        sops.gnupg.sshKeyPaths = [];
        sops.defaultSopsFile = ./nixos/${config.networking.hostName}/secret.yaml;
      };

      # FIXME: This requires IFD and impure.
      fix-qtwayland-crash = { pkgs, ... }: {
        system.replaceRuntimeDependencies = with pkgs; [
          {
            original = qt5.qtwayland;
            replacement = callPackage ./pkgs/qt5wayland.nix { };
          }
          {
            original = qt6.qtwayland;
            replacement = callPackage ./pkgs/qt6wayland { };
          }
        ];
      };

      plsama-5-27 = { config, ... }: {
        nixpkgs.overlays = [
          (final: prev: {
            inherit (inputs.nixpkgs-plasma-5-27.legacyPackages.${config.nixpkgs.system})
              libsForQt5;
          })
        ];

        disabledModules = [ "services/x11/desktop-managers/plasma5.nix" ];
        imports = [
          "${inputs.nixpkgs-plasma-5-27}/nixos/modules/services/x11/desktop-managers/plasma5.nix"
        ];
      };
    };

    mkSystem = name: system: nixpkgs: { extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inputs = inputs // { inherit nixpkgs; };
        my = import ./my // {
          pkgs = self.packages.${system};
        };
      };
      modules = with nixosModules; [
        system-label
        { networking.hostName = lib.mkDefault name; }
        { nixpkgs.overlays = overlays; }
        ./nixos/${name}/configuration.nix
      ] ++ extraModules;
    };

  in {
    inherit nixosModules;

    nixosSystems = lib.mapAttrs
      (name: conf: conf.config.system.build.toplevel)
      self.nixosConfigurations;

    nixosConfigurations = {
      invar = mkSystem "invar" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ home-manager sops fix-qtwayland-crash ];
      };

      blacksteel = mkSystem "blacksteel" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ home-manager sops plsama-5-27 emacs-overlay ];
      };

      minimal-image = mkSystem "minimal-image" "x86_64-linux" inputs.nixpkgs {
        extraModules = with nixosModules; [ home-manager sops plsama-5-27 ];
      };
    };

    images = {
      minimal-iso = self.nixosConfigurations.minimal-image.config.system.build.isoImage;
    };

  } // flake-utils.lib.eachDefaultSystem (system: rec {
    packages = import ./pkgs {
      inherit lib;
      pkgs = nixpkgs.legacyPackages.${system};
    };

    checks = packages;

    devShells.default =
      with nixpkgs.legacyPackages.${system};
      mkShellNoCC {
        packages = [ nvfetcher packages.nixos-rebuild-shortcut ];
      };
  });
}
