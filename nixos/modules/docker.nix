{ pkgs, ... }:

{
  environment.systemPackages = [ 
    pkgs.dockerTools
    pkgs.nix-prefetch-docker
    haskellPackages.hocker
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}