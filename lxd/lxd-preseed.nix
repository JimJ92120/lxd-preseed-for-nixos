# lxd-preseed
#
# `lxd init --preseed < $YAML_FILE` alternative.
# load ./profiles directory with pre-configured lxd network, storage and profile.
#
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/lxd.nix#L95
{ config, lib, ... }:

let
  _LXD_PROFILES = {
    "default" = (import ./profiles/default.nix);
    "dev" = (import ./profiles/dev.nix);
    "private0" = (import ./profiles/private0.nix);
  };
in
{
  virtualisation = {
    lxd = {
      preseed =  {
        networks = [
          _LXD_PROFILES.default.network
          _LXD_PROFILES.dev.network
          _LXD_PROFILES.private0.network
        ];

        profiles = [
          _LXD_PROFILES.default.profile
          _LXD_PROFILES.dev.profile
          _LXD_PROFILES.private0.profile
        ];

        storage_pools = [
          _LXD_PROFILES.default.storage_pool
          _LXD_PROFILES.dev.storage_pool
          _LXD_PROFILES.private0.storage_pool
        ];  
      };
    };
  };
}
