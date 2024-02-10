{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nix-prefetch-docker
    docker-compose
    docker-client
    # docker
    podman
    podman-compose
  ];
  # virtualisation.docker.enable = true;
  # virtualisation.docker.storageDriver = "btrfs";
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      dockerSocket = {
        enable = true;
      };

      # extraPackages = [ pkgs.podman-compose ];

      # networkSocket = {
      #   enable = true;
      # };
    };
  };
  # users.extraGroups.docker.members = [ "yuzuki" ];
  users.extraGroups.podman.members = [ "yuzuki" ];
}
