{ config, pkgs, ... }: 

{
    environment.systemPackages = with pkgs; [
    cudatoolkit
    cudaPackages.cudnn
  ];

  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfree = true;
  };
  
  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };
}