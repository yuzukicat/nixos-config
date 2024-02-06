{
  description = "oxalica's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unmatched.url = "github:oxalica/nixpkgs/test/unmatched";
    nixpkgs-sddm-0-20-0.url = "github:NixOS/nixpkgs/pull/239389/head";

    # Placeholder.
    blank.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.flake-compat.follows = "blank";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    meta-sifive = {
      url = "github:sifive/meta-sifive/2021.11.00";
      flake = false;
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/7e2ecc3654c3daa74a1f72826cac9b8fd13a7f06";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    emacs-upstream = {
      url = "github:yuzukicat/emacs/master";
      flake = false;
    };
    tree-sitter-nix-oxa = {
      url = "github:oxalica/tree-sitter-nix";
      flake = false;
    };
    lsp-nil = {
      url = "github:oxalica/nil";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Optional.
    # secrets.url = "/home/yuzuki/storage/personal/nixos-config/nixos/blacksteel";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    overlays = {
      # FIXME: https://github.com/NixOS/nixpkgs/issues/229358
      sddm = final: prev: {
        libsForQt5 = prev.libsForQt5.overrideScope' (final_: prev_: {
          inherit (inputs.nixpkgs-sddm-0-20-0.legacyPackages.${final.stdenv.system}.libsForQt5) sddm;
        });
      };
    };

    nixosModules = {
      # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
      system-label = {
        system.configurationRevision = self.rev or null;
        system.nixos.label =
          if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
          then "${lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
          else lib.warn "Repo is dirty, revision will not be available in system label" "dirty";
      };

      home-manager = {
        config,
        inputs,
        my,
        ...
      }: {
        imports = [inputs.home-manager.nixosModules.home-manager];
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

      emacs-overlay = {
        pkgs,
        config,
        inputs,
        my,
        ...
      }: {
        nixpkgs.overlays = [
          inputs.emacs-overlay.overlay
          (final: prev: {
            emacs30 = prev.emacs-git.overrideAttrs (old: {
              name = "emacs30";
              version = inputs.emacs-upstream.shortRev;
              src = inputs.emacs-upstream;
            });
            # TODO: figure out a way to import based on this...
            # sys = pkgs.lib.last (pkgs.lib.splitString "-" pkgs.system);
            emacsWithConfig = prev.emacsWithPackagesFromUsePackage {
              # config = builtins.readFile "../../static/emacs/init.org";
              config = let
                readRecursively = dir:
                  builtins.concatStringsSep "\n"
                  (lib.mapAttrsToList (name: value:
                    if value == "regular"
                    then builtins.readFile (dir + "/${name}")
                    else
                      (
                        if value == "directory"
                        then readRecursively (dir + "/${name}")
                        else []
                      ))
                  (builtins.readDir dir));
              in
                readRecursively ./home/modules/emacs;
              # config = ./home/modules/emacs/init.el;
              alwaysEnsure = true;
              package = final.emacs30;
              # Force these two even though they're outside of the org config.
              extraEmacsPackages = epkgs: [
                epkgs.use-package
                epkgs.exec-path-from-shell
                epkgs.llama
                epkgs.direnv
                epkgs.no-littering
                epkgs.transient
                epkgs.good-scroll
                epkgs.centaur-tabs
                epkgs.winum
                epkgs.ligature
                epkgs.list-unicode-display
                epkgs.svg-tag-mode
                epkgs.diminish
                epkgs.hydra
                epkgs.use-package-hydra
                epkgs.all-the-icons
                epkgs.color-identifiers-mode
                epkgs.moody
                epkgs.minions
                epkgs.doom-themes
                epkgs.catppuccin-theme
                epkgs.dired-single
                epkgs.dirvish
                epkgs.ivy
                epkgs.counsel
                epkgs.swiper
                epkgs.ivy-rich
                epkgs.workroom
                epkgs.workgroups2
                epkgs.projectile
                epkgs.counsel-projectile
                epkgs.treemacs
                epkgs.treemacs-projectile
                epkgs.treemacs-icons-dired
                epkgs.treemacs-tab-bar
                epkgs.minimap
                epkgs.dashboard
                epkgs.revert-buffer-all
                epkgs.loc-changes
                epkgs.smartparens
                epkgs.verb
                epkgs.org
                epkgs.org-modern
                epkgs.zoxide
                epkgs.fzf
                epkgs.anzu
                epkgs.git-gutter
                epkgs.undo-tree
                epkgs.magit
                epkgs.flycheck
                epkgs.flymake
                epkgs.mwim
                epkgs.hl-todo
                epkgs.rainbow-mode
                epkgs.rainbow-delimiters
                # markdown dependancty
                epkgs.websocket
                epkgs.web-server
                epkgs.ws-butler
                epkgs.popup
                epkgs.clippy
                epkgs.language-id
                epkgs.cargo-mode
                epkgs.crontab-mode
                epkgs.csv-mode
                epkgs.dockerfile-mode
                epkgs.docker-compose-mode
                epkgs.dotenv-mode
                epkgs.elixir-mode
                epkgs.elixir-ts-mode
                epkgs.elm-mode
                epkgs.go-mode
                epkgs.flymake-go-staticcheck
                epkgs.graphql-mode
                # dependancty for elixir-ts-mode
                epkgs.heex-ts-mode
                epkgs.js2-mode
                epkgs.json-mode
                epkgs.kotlin-mode
                epkgs.lua-mode
                epkgs.markdown-mode
                epkgs.markdown-preview-mode
                epkgs.mermaid-mode
                epkgs.ox-qmd
                epkgs.pandoc
                epkgs.ox-pandoc
                epkgs.ox-spectacle
                epkgs.nix-mode
                epkgs.pnpm-mode
                epkgs.rjsx-mode
                epkgs.rust-mode
                epkgs.lsp-mssql
                epkgs.syntactic-close
                epkgs.lsp-tailwindcss
                epkgs.poetry
                # epkgs.protobuf-mode
                # epkgs.protobuf-ts-mode
                epkgs.prisma-mode
                epkgs.lsp-jedi
                epkgs.lsp-pyright
                epkgs.python-pytest
                epkgs.python-black
                epkgs.python-isort
                epkgs.python-mode
                epkgs.python-x
                epkgs.pet
                epkgs.phps-mode
                epkgs.php-mode
                epkgs.ob-php
                epkgs.flymake-phpstan
                epkgs.pyinspect
                epkgs.python-docstring
                epkgs.numpydoc
                epkgs.python-cell
                epkgs.typescript-mode
                epkgs.tide
                epkgs.web-mode
                epkgs.x509-mode
                epkgs.yaml-pro
                epkgs.yaml-mode
                epkgs.toml
                epkgs.pcsv
                epkgs.pdf-tools
                epkgs.ascii-table
                epkgs.cargo
                epkgs.eldoc
                epkgs.isearch-mb
                epkgs.rg
                epkgs.olivetti
                epkgs.qrencode
                epkgs.request
                epkgs.slime
                epkgs.citre
                epkgs.format-all
                epkgs.simple-call-tree
                epkgs.symbol-overlay
                epkgs.wrap-region
                epkgs.tempel
                epkgs.tempel-collection
                epkgs.yasnippet
                epkgs.yasnippet-snippets
                epkgs.lsp-mode
                epkgs.lsp-ui
                epkgs.lsp-treemacs
                epkgs.posframe
                epkgs.popon
                epkgs.acm-terminal
                epkgs.lsp-bridge
                epkgs.acm
                epkgs.dumb-jump
                epkgs.org
                epkgs.org-ai
                epkgs.org-inline-anim
                epkgs.khalel
                epkgs.org-habit-stats
                epkgs.org-mime
                epkgs.org-tidy
                epkgs.org-ref
                epkgs.ivy-bibtex
                epkgs.org-roam-bibtex
                epkgs.citar
                epkgs.embark
                epkgs.citar-embark
                epkgs.org-ivy-search
                epkgs.org-recur
                epkgs.org-ql
                epkgs.orgtbl-aggregate
                epkgs.orgtbl-join
                epkgs.orgtbl-fit
                epkgs.osm
                epkgs.multiple-cursors
                epkgs.tree-sitter
                epkgs.apel
                epkgs.flim
                epkgs.semi
                epkgs.w3m
                epkgs.wanderlust
                # epkgs.tree-sitter-langs
                (epkgs.tree-sitter-langs.withPlugins
                  # Install all tree sitter grammars available from nixpkgs
                  (grammars:
                    builtins.filter lib.isDerivation (lib.attrValues (grammars
                      // {
                        tree-sitter-nix = grammars.tree-sitter-nix.overrideAttrs (old: {
                          version = "fixed";
                          src = inputs.tree-sitter-nix-oxa;
                        });
                      }))))
                epkgs.treesit-auto
                epkgs.imenu-list
                epkgs.quelpa
                epkgs.quelpa-leaf
                epkgs.quelpa-use-package
                epkgs.interaction-log
                epkgs.json-reformat
                epkgs.json-snatcher
                epkgs.auctex
                # (epkgs.melpaBuild rec {
                #   pname = "mind-wave";
                #   version = "20230324.1348"; # 13:12 UTC
                #   src = pkgs.fetchFromGitHub {
                #     owner = "manateelazycat";
                #     repo = "mind-wave";
                #     rev = "994618abcd2c6a09af49b486d270ad4fd2d5b4a4";
                #     sha256 = "sha256-IRT+ct8X2W/iS4+aIoibwR0br5FHWBDYCeNP8pGrpJs=";
                #   };
                #   commit = "994618abcd2c6a09af49b486d270ad4fd2d5b4a4";
                #   packageRequires = [
                #     pkgs.emacsPackages.markdown-mode
                #   ];
                #   buildInputs = [
                #     (pkgs.python3.withPackages (ps:
                #       with ps; [
                #         openai
                #         epc
                #         sexpdata
                #         six
                #       ]))
                #   ];
                #   recipe = pkgs.writeText "recipe" ''
                #     (mind-wave
                #       :repo "manateelazycat/mind-wave"
                #       :fetcher github
                #       :files
                #       ("mind-wave.el"
                #       "mind-wave-epc.el"
                #       "mind_wave.py"
                #       "utils.py"))
                #   '';
                #   doCheck = true;
                #   passthru.updateScript = pkgs.unstableGitUpdater {};
                #   meta = with lib; {
                #     description = " Emacs AI plugin based on ChatGPT API ";
                #     homepage = "https://github.com/manateelazycat/mind-wave";
                #     license = licenses.gpl3Only;
                #     maintainers = with maintainers; [yuzukicat];
                #   };
                # })
              ];
              override = epkgs:
                epkgs
                // {
                  # lsp-bridge = pkgs.callPackage ./lsp-bridge.nix {
                  #   inherit (pkgs) fetchFromGitHub;
                  #   inherit (epkgs) trivialBuild posframe markdown-mode yasnippet;
                  # };
                };
            };
          })
        ];
      };

      sops = {config, ...}: {
        imports = [inputs.sops-nix.nixosModules.sops];
        sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        sops.gnupg.sshKeyPaths = [];
        sops.defaultSopsFile = ./nixos/${config.networking.hostName}/secret.yaml;
      };
    };

    mkSystem = name: system: nixpkgs: {extraModules ? []}:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inputs = inputs // {inherit nixpkgs;};
          my =
            import ./my
            // {
              pkgs = self.packages.${system};
            };
        };
        modules = with nixosModules;
          [
            system-label
            {networking.hostName = lib.mkDefault name;}
            {nixpkgs.overlays = builtins.attrValues overlays;}
            ./nixos/${name}/configuration.nix
          ]
          ++ extraModules;
      };
  in
    {
      inherit overlays nixosModules;

      lib = import ./lib.nix {
        inherit (nixpkgs) lib;
      };

      nixosSystems =
        lib.mapAttrs
        (name: conf: conf.config.system.build.toplevel)
        self.nixosConfigurations;

      nixosConfigurations = {
        invar = mkSystem "invar" "x86_64-linux" inputs.nixpkgs {
          extraModules = with nixosModules; [home-manager sops emacs-overlay];
        };

        blacksteel = mkSystem "blacksteel" "x86_64-linux" inputs.nixpkgs {
          extraModules = with nixosModules; [home-manager sops emacs-overlay];
        };

        lithium = mkSystem "lithium" "x86_64-linux" inputs.nixpkgs {
          extraModules = with nixosModules; [home-manager sops emacs-overlay];
        };

        unmatched = mkSystem "unmatched" "riscv64-linux" inputs.nixpkgs-unmatched {};
        unmatched-cross = mkSystem "unmatched" "x86_64-linux" inputs.nixpkgs-unmatched {
          extraModules = [
            {nixpkgs.crossSystem.config = "riscv64-unknown-linux-gnu";}
          ];
        };

        minimal-image-stable = mkSystem "minimal-image" "x86_64-linux" inputs.nixpkgs-stable {};
        minimal-image-unstable = mkSystem "minimal-image" "x86_64-linux" inputs.nixpkgs {
          extraModules = with nixosModules; [home-manager sops emacs-overlay];
        };
      };

      images = {
        minimal-iso-stable = self.nixosConfigurations.minimal-image-stable.config.system.build.isoImage;
        minimal-iso-unstable = self.nixosConfigurations.minimal-image-unstable.config.system.build.isoImage;
      };
      templates = {
        rust-bin = {
          description = "A simple Rust project for binaries";
          path = ./templates/rust-bin;
        };
        rust-lib = {
          description = "A simple Rust project for libraries";
          path = ./templates/rust-lib;
        };
        ci-rust = {
          description = "A sample GitHub CI setup for Rust projects";
          path = ./templates/ci-rust;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: rec {
      packages = import ./pkgs {
        inherit lib inputs;
        pkgs = nixpkgs.legacyPackages.${system};
      };

      checks = packages;

      devShells.default = with nixpkgs.legacyPackages.${system};
        mkShellNoCC {
          packages = [nvfetcher packages.nixos-rebuild-shortcut];
        };
    });
}
