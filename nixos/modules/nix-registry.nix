{
  lib,
  inputs,
  ...
}: {
  # nix.registry = {
  #   nixpkgs.flake = inputs.nixpkgs;
  #   rust-overlay.flake = inputs.rust-overlay;
  #   flake-utils.flake = inputs.flake-utils;
  #   nocargo.flake = inputs.nocargo;
  # };
  nix.registry =
    lib.mapAttrs (name: value: {
      flake = value;
    })
    inputs;
}
