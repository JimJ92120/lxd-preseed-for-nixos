# lxd-profiles-default
#
# default profile, storage, bridge
#
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/lxd.nix#L95
{
  network = {
    name = "lxdBrDefault";
    type = "bridge";

    config = {
      "ipv4.address" = "10.100.1.1/8";
      "ipv4.nat" = "true";
    };
  };

  storage_pool = {
    name = "default";
    driver = "dir";
  };

  profile = {
    name = "default";
    devices = {
      "eth0" = {
        name = "eth0";
        nictype = "bridged";
        parent = "lxdBrDefault";
        type = "nic";
      };
      "root" = {
        path = "/";
        pool = "default";
        size = "16GiB";
        type = "disk";
      };
    };
  };
}
