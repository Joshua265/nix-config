{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    autoAddDriverRunpath
  ];

  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfree = true;
    cudaCapabilities = ["8.6"];
  };

  systemd.services.nvidia-control-devices = {
    wantedBy = ["multi-user.target"];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };
}
