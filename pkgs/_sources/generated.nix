# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  browsh = {
    pname = "browsh";
    version = "d32ae0ba5a1df266b96772fcd0b62ab8a76429ac";
    src = fetchFromGitHub {
      owner = "browsh-org";
      repo = "browsh";
      rev = "d32ae0ba5a1df266b96772fcd0b62ab8a76429ac";
      fetchSubmodules = false;
      sha256 = "sha256-LUHLaIW6aFa9yFJ+yqlkZtTk5LzN7r6xzHJKXWC2JnA=";
    };
    vendorHash = "sha256-eCvV3UuM/JtCgMqvwvqWF3bpOmPSos5Pfhu6ETaS58c=";
    date = "2023-02-02";
  };
  cmdg = {
    pname = "cmdg";
    version = "1c2fe5b72affaf19ff47033b0dfe744c37b49632";
    src = fetchFromGitHub {
      owner = "yuzukicat";
      repo = "cmdg";
      rev = "1c2fe5b72affaf19ff47033b0dfe744c37b49632";
      fetchSubmodules = false;
      sha256 = "sha256-oX5K7un9+LJQ9G+dNj4giIjq8BPBhzB5bAj+1ceS7nE=";
    };
    vendorHash = "sha256-p7p1GdwL+VqP7wHEmYwhc/CYKgMUFt7OYigWNGkJ2n8=";
    date = "2023-05-23";
  };
  colors = {
    pname = "colors";
    version = "94d8b2be62657e96488038b0e547e3009ed87d40";
    src = fetchurl {
      url = "https://gist.githubusercontent.com/lilydjwg/fdeaf79e921c2f413f44b6f613f6ad53/raw/94d8b2be62657e96488038b0e547e3009ed87d40/colors.py";
      sha256 = "sha256-l/RTPZp2v7Y4ffJRT5Fy5Z3TDB4dvWfE7wqMbquXdJA=";
    };
  };
  double-entry-generator = {
    pname = "double-entry-generator";
    version = "v2.4.0";
    src = fetchFromGitHub {
      owner = "deb-sig";
      repo = "double-entry-generator";
      rev = "v2.4.0";
      fetchSubmodules = false;
      sha256 = "sha256-XJsectuh2yO4t3nWi0aoBoNNf4AzxXtTmR/e6wrMzKk=";
    };
    vendorHash = "sha256-Xedva9oGteOnv3rP4Wo3sOHIPyuy2TYwkZV2BAuxY4M=";
  };
  eml2md = {
    pname = "eml2md";
    version = "ca831e1e3661c51d4918344c4a448fa9b1da2144";
    src = fetchFromGitHub {
      owner = "elda27";
      repo = "eml2md";
      rev = "ca831e1e3661c51d4918344c4a448fa9b1da2144";
      fetchSubmodules = false;
      sha256 = "sha256-jNASJG7SRVZ4AYPkNBmqVn3x0tQQTmMFtpC5mck2WXk=";
    };
    date = "2022-11-29";
  };
  gopls = {
    pname = "gopls";
    version = "84f829e2765ff8c96a27cf9e42507d48670c36ee";
    src = fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "84f829e2765ff8c96a27cf9e42507d48670c36ee";
      fetchSubmodules = false;
      sha256 = "sha256-QfSp+kDKwymlHqEJkDnyXaIrmbWyTCOEg96IhRfS5II=";
    };
    vendorSha256 = "sha256-xSbL2bCPFvuYKnuvwvzw4bvMjIVLZd4vJbi/FacpSCg=";
    date = "2023-07-18";
  };
  gotools = {
    pname = "gotools";
    version = "84f829e2765ff8c96a27cf9e42507d48670c36ee";
    src = fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "84f829e2765ff8c96a27cf9e42507d48670c36ee";
      fetchSubmodules = false;
      sha256 = "sha256-QfSp+kDKwymlHqEJkDnyXaIrmbWyTCOEg96IhRfS5II=";
    };
    vendorSha256 = "sha256-Nbpd4nNYfCTEw1trMXxTVZwSZ5CbUv0hAAi+0eDJLWU=";
    date = "2023-07-18";
  };
  lsp-bridge = {
    pname = "lsp-bridge";
    version = "4758674e21daef8a277286384457bc7adcd2029a";
    src = fetchFromGitHub {
      owner = "manateelazycat";
      repo = "lsp-bridge";
      rev = "4758674e21daef8a277286384457bc7adcd2029a";
      fetchSubmodules = false;
      sha256 = "sha256-1DWHkS9UDQ13svnZ6raMMc5OM5eQJ3pXQEnlLaLINlM=";
    };
    date = "2023-07-19";
  };
  mind-wave = {
    pname = "mind-wave";
    version = "1ae7b7be74fa1f37b18f9031d127a563e2434617";
    src = fetchFromGitHub {
      owner = "manateelazycat";
      repo = "mind-wave";
      rev = "1ae7b7be74fa1f37b18f9031d127a563e2434617";
      fetchSubmodules = false;
      sha256 = "sha256-mmt5Ova2n3/E2Ry5IoKRrRIwWK1jHXU4WgzzGyMNeOM=";
    };
    date = "2023-07-04";
  };
  ohmyzsh-theme-passion = {
    pname = "ohmyzsh-theme-passion";
    version = "1d96f9984d581bbf6b64b940599786a9c91e2ad6";
    src = fetchFromGitHub {
      owner = "ChesterYue";
      repo = "ohmyzsh-theme-passion";
      rev = "1d96f9984d581bbf6b64b940599786a9c91e2ad6";
      fetchSubmodules = false;
      sha256 = "sha256-9mxHmMeA/tNO0axc8cQD1MzWsG0GIJc8a57MXKycZf4=";
    };
    date = "2023-05-19";
  };
  openai-whisper-cpp = {
    pname = "openai-whisper-cpp";
    version = "39984657218588a26a413fff642b77c5d5232e51";
    src = fetchFromGitHub {
      owner = "ggerganov";
      repo = "whisper.cpp";
      rev = "39984657218588a26a413fff642b77c5d5232e51";
      fetchSubmodules = false;
      sha256 = "sha256-8GW01ITzGLAdSX3r3z02+jdPfoSN4y/IFjhN8906k2o=";
    };
    date = "2023-07-16";
  };
  xpi = {
    pname = "xpi";
    version = "1.8.2";
    src = fetchurl {
      url = "https://github.com/browsh-org/browsh/releases/download/v1.8.2/browsh-1.8.2.xpi";
      sha256 = "sha256-04rLyQt8co3Z7UJnDJmj++E4n7of0Zh1jQ90Bfwnx5A=";
    };
  };
}
