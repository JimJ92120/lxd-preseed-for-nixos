# lxd-networking
#
# only forwarding
# interfaces are managed in `lxd-preseed.yaml` by lxd
{ config, lib, ... }:

let
  _LXD_PROFILES = {
    "default" = (import ./profiles/default.nix);
    "dev" = (import ./profiles/dev.nix);
    "private0" = (import ./profiles/private0.nix);
  };
in
{
  boot = {
    kernelModules = [ "nf_nat_ftp" ];

    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
    };
  };
  
  # allow static ipv4 for containers
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i ${_LXD_PROFILES.default.network.name} -m comment --comment "lxd rule for ${_LXD_PROFILES.default.network.name}" -j ACCEPT
    iptables -A INPUT -i ${_LXD_PROFILES.dev.network.name} -m comment --comment "lxd rule for ${_LXD_PROFILES.dev.network.name}" -j ACCEPT
    iptables -A INPUT -i ${_LXD_PROFILES.private0.network.name} -m comment --comment "lxd rule for ${_LXD_PROFILES.private0.network.name}" -j ACCEPT
  '';
}
