# lxd-profiles-private
#
# private network for work, private project(s), etc...
#
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/lxd.nix#L95
{
  network = {
    name = "lxdBrPrivate0";
    type = "bridge";

    config = {
      "ipv4.address" = "10.110.1.1/16";
      "ipv4.nat" = "true";
    };
  };

  storage_pool = {
    name = "private0";
    driver = "dir";
  };

  profile = {
    name = "private0";
    devices = {
      "eth0" = {
        name = "eth0";
        nictype = "bridged";
        parent = "lxdBrPrivate0";
        type = "nic";
      };
      "root" = {
        path = "/";
        pool = "private0";
        size = "24GiB";
        type = "disk";
      };
    };
  };
}
