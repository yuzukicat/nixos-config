{ lib, buildNpmPackage, source }:

buildNpmPackage rec {
  inherit (source) pname src npmDepsHash;
  version = lib.removePrefix "v" source.version;

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  NODE_OPTIONS = "--openssl-legacy-provider";

   postPatch = ''
     cp ${./package-lock.json} package-lock.json
   '';

  meta = with lib; {
    description = "The AWS Amplify CLI is a toolchain for simplifying serverless web and mobile development.";
    homepage = "https://github.com/aws-amplify/amplify-cli";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ yuzukicat ];
  };
}
