{ lib, buildGoModule, source }:

buildGoModule rec {
  inherit (source) pname src vendorSha256;
  version = lib.removePrefix "v" source.version;

  postPatch = ''
    # The gopls folder contains a Go submodule which causes a build failure
    # and lives in its own package named gopls.
    rm -r gopls
    # getgo is an experimental go installer which adds generic named server and client binaries to $out/bin
    rm -r cmd/getgo
  '';

  doCheck = false;

  # Set GOTOOLDIR for derivations adding this to buildInputs
  postInstall = ''
    mkdir -p $out/nix-support
    substitute ${./setup-hook.sh} $out/nix-support/setup-hook \
      --subst-var-by bin $out
  '';

  meta = with lib; {
    description = "Additional tools for Go development";
    longDescription = ''
      This package contains tools like: godoc, goimports, callgraph, digraph, stringer or toolstash.
    '';
    homepage = "https://go.googlesource.com/tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [ danderson SuperSandro2000 yuzukicat];
  };
}
