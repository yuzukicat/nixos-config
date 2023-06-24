{ lib, source, buildGoModule }:
buildGoModule rec {
  inherit (source) pname src vendorHash;
  version = lib.removePrefix "v" source.version;
  subPackages = [ "cmd/cmdg" ];
  meta = with lib; {
    description = "Command line Gmail client";
    homepage = "https://github.com/ThomasHabets/cmdg";
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [ ThomasHabets Yuzukicat ];
  };
}
