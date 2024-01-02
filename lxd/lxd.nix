# lxd
{
  imports = [
    ./lxd-preseed.nix
    ./lxd-networking.nix
  ];

  virtualisation = {
    lxd = {
      enable = true;

      recommendedSysctlSettings = true;
    };s

    lxc = {
      lxcfs.enable = true;
    };
  };
}
