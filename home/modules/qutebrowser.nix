{ 
  programs.qutebrowser = {
    enable = true;

    settings = {

      colors = with {
        black   = "#1d1f21";
        red     = "#cc6666";
        green   = "#b5bd68";
        yellow  = "#f0c674";
        blue    = "#81a2be";
        magenta = "#b294bb";
        cyan    = "#8abeb7";
        white   = "#ffffff";
      };

      {
          completion = {
            category = {
              border = {
                bottom = black;
                top = black;
              };
              bg = black;
              fg = white;
            };

            even.bg = black;
            odd.bg  = black;
            fg = [ white white white ];

            item.selected = {
              bg = yellow;
              fg = black;
              border.bottom = yellow;
              border.top = yellow;
            };
          }; 

          hints = {
            bg = yellow;
            fg = black;
            match.fg = red;
          };

          tabs = {
            selected.even.bg = black;
            selected.odd.bg  = black;
            selected.even.fg = white;
            selected.odd.fg  = white;
          };

          statusbar.normal.bg = black;
          statusbar.normal.fg = white;
          statusbar.command.bg = black;
          statusbar.command.fg = white;

          downloads.bar.bg = black;

          messages = {
            info.bg = black;
            info.border = black;
            info.fg = white;

            error.bg = red;
            error.border = red;
            error.fg = white;

            warning.bg = magenta;
            warning.border = magenta;
            warning.fg = white;
          };
      };
    };
    quickmarks = {
      nixpkgs = "https://search.nixos.org/packages?";
      nixopts = "https://search.nixos.org/options?";
      append = "https://rycee.gitlab.io/home-manager/options.html";
      github = "https://github.com";
      duck = "https://duckduckgo.com";
      twitter = "https://twitter.com";
      google = "https://www.google.com";
      deepl = "https://www.deepl.com/translate";
      googledrive = "https://drive.google.com";
      lookerstudio = "https://lookerstudio.google.com/navigation/reporting";
    };
    # TODO
  };
}
