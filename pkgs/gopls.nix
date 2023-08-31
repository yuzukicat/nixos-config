{ lib, buildGoModule, fetchFromGitHub, source }:

buildGoModule rec {
  inherit (source) pname vendorSha256;
  version = lib.removePrefix "v" source.version;

  src = fetchFromGitHub {
    owner = "golang";
    repo = "tools";
    rev = "gopls/v${version}";
    sha256 = "sha256-vTGyEq65crhius8EzuaBSgUrUc3e7P1X7v76qaYjXus=";
  };

  modRoot = "gopls";

  doCheck = false;

  # Only build gopls, and not the integration tests or documentation generator.
  subPackages = [ "." ];

  meta = with lib; {
    description = "Official language server for the Go language";
    homepage = "https://github.com/golang/tools/tree/master/gopls";
    license = licenses.bsd3;
    maintainers = with maintainers; [ mic92 rski SuperSandro2000 zimbatm yuzukicat ];
  };
}
