{ lib, pkgs, config, my, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$HOME/.local/bin\${PATH:+:}$PATH";

    FZF_DEFAULT_COMMAND = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--layout=reverse" # Top-first.
      "--color=light"
      "--info=inline"
      "--exact" # Substring matching by default, `'`-quote for subsequence matching.
      "--bind=alt-p:toggle-preview,alt-a:select-all"
    ];

    BAT_THEME = "ansi";
  };

  # The default `command-not-found` relies on nix-channel. Use `nix-index` instead.
  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    # Don't install the hook.
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    dirHashes = {
      target = "${config.xdg.cacheHome}/cargo/target";
      nixpkgs = "${config.home.homeDirectory}/repo/fork/nixpkgs";
    };

    defaultKeymap = "emacs";

    # Disable /etc/{zshrc,zprofile} that contains the "sane-default" setup.
    # See `/etc/zshrc` for more info.
    envExtra = ''
      setopt no_global_rcs
    '';

    enableAutosuggestions = true;
    enableCompletion = false; # We do it ourselves.
    enableVteIntegration = true;
    syntaxHighlighting.enable = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = false;
      path = "${config.xdg.stateHome}/zsh/history";
      save = 1000000;
      size = 1000000;
      ignorePatterns = [
        "rm *" "\\rm *"
        "sudo *rm*"
        "task *(append|add|delete|perge|done|modify)*"
        ":"
      ];
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        # "colorize"
        "docker"
        "docker-compose"
        "dotenv"
        "emacs"
        "emoji"
        "emoji-clock"
        "encode64"
        "git-prompt"
        "golang"
        "history"
        "iterm2"
        "ng"
        "nmap"
        "npm"
        "pip"
        "python"
        "pyenv"
        "postgres"
        "rust"
        "systemadmin"
        "torrent"
        "urltools"
        "zsh-interactive-cd"
      ];
      # custom = "${config.home.homeDirectory}/.oh-my-zsh/custom";
      # theme = "passion";
    };

    # Ref: https://blog.quarticcat.com/zh/posts/how-do-i-make-my-zsh-smooth-as-fuck/
    # bash
    initExtra = ''
      setopt auto_pushd
      setopt interactive_comments
      setopt multios
      setopt noextended_glob # Breaks flake path reference nixpkgs#foo.
      setopt hist_verify
      setopt inc_append_history_time
      export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'
      TIMEFMT=$'%J  %uU user %uS system %uE/%*E elapsed %PCPU (%Xavgtext+%Davgdata %Mmaxresident)k\n%Iinputs+%Ooutputs (%Fmajor+%Rminor)pagefaults %Wswaps'
      source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
      source ${./prompt.zsh}
      source ${./cmds.zsh}
      source ${./key-bindings.zsh}
      source ${./completion.zsh}
      source ${../omz/passion.zsh-theme}

      ZSH_AUTOSUGGEST_MANUAL_REBIND=1
      ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'*\n*'
      ZSH_THEME="passion"
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
      source ${my.pkgs.zsh-comma}/share/zsh/comma/comma.zsh
      FAST_HIGHLIGHT[use_async]=1 # Improve paste delay for nix store paths.
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    '';
  };

  programs.zoxide.enable = true;

  home.packages = with pkgs; with libsForQt5; with plasma5; with kdeGear; with kdeFrameworks; [
    nix-zsh-completions # Prefer nix's builtin completion.
    zsh-nix-shell # Use zsh for nix
    fzf bat # WARN: They are used by fzf.vim!
    my.pkgs.colors my.pkgs.zsh-comma fzf-zsh
    nmap screen
  ];
}
