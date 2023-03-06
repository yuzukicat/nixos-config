{ lib, pkgs, my, inputs, ... }:
{
  # Reduce the closure size.
  # fonts.fontconfig.enable = lib.mkDefault false;

  # Default:
  # - nano # Already have vim.
  # - perl # No.
  # - rsync strace # Already in systemPackages.
  environment.defaultPackages = with pkgs; [ ];

  environment.systemPackages = with pkgs; [
    cntr nix-top # Nix helpers.
    procs # procs zsh
    ncdu # Ncdu is a disk usage analyzer with an ncurses interface
    swapview smartmontools pciutils # lspci
    usbutils # System info.
    curl git strace pv # Monitoring of data being sent through pipe, including copying file.
    exa # exa --long --header --recurse
    fd ripgrep lsof jq loop bc file # Determine the type of a file and its data. Doesn't take the file extension into account, and runs a series of tests to discover the type of file data.
    rsync dnsutils # dig example.com MX +short; nslookup example.com
    my.pkgs.rawmv # Utilities.
    e2fsprogs # For ext234.
    compsize # Filesystems.
    gnupg age pwgen # pwgen -c -n -s -v -B
    sops ssh-to-age # Crypto.
    libarchive zstd # Compression.

    my.pkgs.nixos-rebuild-shortcut
    tmuxPlugins.nord

    wget home-manager

    (emacsWithPackagesFromUsePackage {
      # Your Emacs config file. Org mode babel files are also
      # supported.
      # NB: Config files cannot contain unicode characters, since
      #     they're being parsed in nix, which lacks unicode
      #     support.
      # config = ./emacs.org;
      config = ./emacs/init.el;

      # Whether to include your config as a default init file.
      # If being bool, the value of config is used.
      # Its value can also be a derivation like this if you want to do some
      # substitution:
      #   defaultInitFile = pkgs.substituteAll {
      #     name = "default.el";
      #     src = ./emacs.el;
      #     inherit (config.xdg) configHome dataHome;
      #   };
      defaultInitFile = true;

      # Package is optional, defaults to pkgs.emacs
      package = pkgs.emacsGitNativeComp;

      # By default emacsWithPackagesFromUsePackage will only pull in
      # packages with `:ensure`, `:ensure t` or `:ensure <package name>`.
      # Setting `alwaysEnsure` to `true` emulates `use-package-always-ensure`
      # and pulls in all use-package references not explicitly disabled via
      # `:ensure nil` or `:disabled`.
      # Note that this is NOT recommended unless you've actually set
      # `use-package-always-ensure` to `t` in your config.
      alwaysEnsure = true;

      # For Org mode babel files, by default only code blocks with
      # `:tangle yes` are considered. Setting `alwaysTangle` to `true`
      # will include all code blocks missing the `:tangle` argument,
      # defaulting it to `yes`.
      # Note that this is NOT recommended unless you have something like
      # `#+PROPERTY: header-args:emacs-lisp :tangle yes` in your config,
      # which defaults `:tangle` to `yes`.
      alwaysTangle = true;

      # Optionally provide extra packages not in the configuration file.
      extraEmacsPackages = epkgs: [
        epkgs.cask
      ];

      # Optionally override derivations.
      override = epkgs: epkgs // {
        # weechat = epkgs.melpaPackages.weechat.overrideAttrs(old: {
        #   patches = [ ./weechat-el.patch ];
        # });
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
      };
    })
  ];

  programs.less = { # Dealing with a large text file page by page, resulting in fast loading speeds.
    enable = true;
    lessopen = null;
  };
  environment.variables = let
    common = [
      "--RAW-CONTROL-CHARS" # Only allow colors.
      "--mouse"
      "--wheel-lines=5"
      "--LONG-PROMPT"
    ];
  in {
    PAGER = "less";
    # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
    LESS = lib.concatStringsSep " " common;
    SYSTEMD_LESS = lib.concatStringsSep " " (common ++ [
      "--quit-if-one-screen"
      "--chop-long-lines"
      "--no-init" # Keep content after quit.
    ]);
  };

  # Don't stuck for searching missing commands.
  programs.command-not-found.enable = false;

  programs.iftop.enable = true; # iftop -i wlp6s0
  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.mtr.enable = true; #mtr -4 example.com
  programs.tmux.enable = true;

  # programs.nano.defaultEditor = true;

  # Some defaults, override "basics.nix"
  # programs.gnupg.agent.pinentryFlavor = "qt";
  services.flatpak.enable = true; #  A framework for distributing desktop applications across various Linux distributions.
  services.emacs = {
    package = pkgs.emacsGitNativeComp;
    enable = true;
  };
  # To use VS Code under Wayland, set the environment variable NIXOS_OZONE_WL=1:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
