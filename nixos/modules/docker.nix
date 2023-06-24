{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nix-prefetch-docker
    docker-compose
    docker-client
    docker
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  users.extraGroups.docker.members = [ "yuzuki" ];
}
