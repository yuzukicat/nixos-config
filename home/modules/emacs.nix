pkgs: epkgs: with epkgs;
[
  (trivialBuild rec {
    pname = "toggle-one-window";
    ename = pname;
    version = "git";
    src = inputs.epkgs-toggle-one-window;
  })
]