{ lib, config, pkgs, inputs, my, ... }:
let
  inherit (pkgs) vimPlugins;

  vimrc = builtins.readFile ./vimrc.vim;

  vimrc' = builtins.replaceStrings
    ["@fcitx5-remote@"]
    ["${lib.getBin pkgs.fcitx5}/bin/fcitx5-remote"]
    vimrc;
  
  lspVimrcConfig = builtins.readFile ./base-neovim-config.lua;

  extraConfig = builtins.readFile ./extra-neovim-config.vim;

  plugins =
    map (x: vimPlugins.${lib.elemAt x 0})
      (lib.filter (x: lib.isList x)
        (builtins.split ''" plugin: ([A-Za-z_-]+)'' vimrc)) ++
    cocPlugins;

  cocPlugins = with vimPlugins; [
    coc-pyright
    coc-rust-analyzer
    coc-sumneko-lua
    coc-tsserver
  ];

  cocSettings = {
    "coc.preferences.currentFunctionSymbolAutoUpdate" = true;
    "coc.preferences.extensionUpdateCheck" = "never";
    "diagnostic.errorSign" = "⮾ ";
    "diagnostic.hintSign" = "💡";
    "diagnostic.infoSign" = "🛈 ";
    "diagnostic.warningSign" = "⚠";
    "links.tooltip" = true;
    "semanticTokens.enable" = true;
    "suggest.noselect" = true;

    "[rust]"."coc.preferences.formatOnSave" = true;

    "pyright.server" = "${lib.getBin pkgs.pyright}/bin/pyright-langserver";

    "rust-analyzer.updates.checkOnStartup" = false;
    "rust-analyzer.server.path" = "${lib.getBin pkgs.rust-analyzer}/bin/rust-analyzer";
    "rust-analyzer.checkOnSave.command" = "clippy";
    "rust-analyzer.imports.granularity.group" = "module";
    "rust-analyzer.semanticHighlighting.strings.enable" = false;

    "sumneko-lua.checkUpdate" = false;
    # https://github.com/xiyaowong/coc-sumneko-lua/issues/22#issuecomment-1252284377
    "sumneko-lua.serverDir" = "${pkgs.sumneko-lua-language-server}/share/lua-language-server";
    "Lua.misc.parameters" = [
      "--metapath=${config.xdg.cacheHome}/sumneko_lua/meta"
      "--logpath=${config.xdg.cacheHome}/sumneko_lua/log"
    ];

    languageserver = {
      nix = {
        # Use from PATH to allow overriding.
        command = "nil";
        filetypes = [ "nix" ];
        rootPatterns = [ "flake.nix" ".git" ];
        settings.nil = {
          formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
      };
    };
  };



  # bat.vim syntax highlighting:
  bat-vim = pkgs.vimUtils.buildVimPlugin {
    name = "bat.vim";
    src = pkgs.fetchFromGitHub {
      owner = "jamespwilliams";
      repo = "bat.vim";
      rev = "e2319b07ed6e74cdd70df2be6e8bf066377e22f7";
      sha256 = "0bmlvziha1crk7x7p1yzdsb55bvpsj434sc28r7xspin9kfnd6y9";
    };
  };

  overriden-neovim =
    pkgs.neovim.override {
      configure = {
        customRC = vimrc;
        packages.packages = with pkgs.vimPlugins; {
          start = [
            bat-vim
            nvim-lspconfig
            (nvim-treesitter.withPlugins (
              plugins: with plugins; [
                tree-sitter-go
              ]
            ))
            sensible
          ];
        }; 
      };     
    };

in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    inherit plugins;
    extraConfig = vimrc';

    coc = {
      enable = true;
      settings = cocSettings;
    };
  };

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    nil
    go_1_18
    gopls
    overriden-neovim
    tmux
  ];
}
