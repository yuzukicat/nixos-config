{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs.cudaPackages; [
    cudnn
    cudatoolkit
  ];
  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };
}
