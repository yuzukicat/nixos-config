{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ 
    nix-prefetch-docker
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}