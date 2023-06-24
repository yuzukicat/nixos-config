# Reference: https://gitlab.com/NickCao/flakes/-/blob/master/nixos/local/home.nix#L71
{ config, ... }:
{

  xdg.enable = true;

  home.sessionVariables = {
    HISTFILE = "${config.xdg.stateHome}/bash/history";
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    SQLITE_HISTORY = "${config.xdg.stateHome}/sqlite/history";
  };

  # XDG Spec doens't have BIN_HOME yet.
  xdg.configFile."go/env".text = ''
    GOPATH=${config.xdg.cacheHome}/go
    GOBIN=${config.home.homeDirectory}/.local/bin
  '';
}
