# lxd-networking
#
# only forwarding
# interfaces are managed in `lxd-preseed.yaml` by lxd
{
  boot = {
    kernelModules = [ "nf_nat_ftp" ];

    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
    };
  };
}
