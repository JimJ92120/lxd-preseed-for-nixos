# lxd-profiles-dev
#
# a seprated network (from `main`, `default`, etc) for development, testing, etc...
#
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/lxd.nix#L95
{
  network = {
    name = "lxdBrDev";
    type = "bridge";

    config = {
      "ipv4.address" = "10.10.1.1/16";
      "ipv4.nat" = "true";
    };
  };

  storage_pool = {
    name = "dev";
    driver = "dir";
  };

  profile = {
    name = "dev";
    devices = {
      "eth0" = {
        name = "eth0";
        nictype = "bridged";
        parent = "lxdBrDev";
        type = "nic";
      };
      "root" = {
        path = "/";
        pool = "dev";
        size = "16GiB";
        type = "disk";
      };
    };
  };
}
