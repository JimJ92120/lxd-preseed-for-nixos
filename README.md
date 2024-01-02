# lxd-in-nixos

A `preseed(ed)` configuration for `lxd` in a `nixos` host, to **declare** any `lxd` options and configurations.

Example will setup different profiles, networks and storages to use for different workflow and projects.  
This comes in handy:

- **for development**: user may run new containers to avoid any **global setup** or projects interfering with each others
- **for servers**: to quickly spin up `lxd` containers in a **declarative** way (VS **imperative**)
- **security**: with proper configuration, networks may be fully isolated - some work, projects do require such option

`./lxd-preseed.yaml` translates all `.nix` configurations declared into "standard" `.yaml` format.

The following will be setup through the example:  
![lxd-in-nixos](https://github.com/JimJ92120/lxd-preseed-for-nixos/assets/57893611/1c005450-16cd-4dd5-8b08-613713f85543)  

### important note

If attempting to **add OR edit** such configuration to an existing **NixOS** host with **LXD** already configured and running, this may cause conflicts.  
"Easiest" is to:

1. disable `lxd` from `configuration.nix`

   ```nix
   {
    virtualisation.lxd.enabled = false;

    # and comment all previous `lxd` related configurations
   }
   ```

2. rebuild with `nixos-rebuild switch` ADN `nixos-rebuild boot`
3. reboot
4. re-enable `lxd` with new configurations

---

---

# introduction

Project allows setting up `lxd` through `nixos` configuration file `/etc/nixos/configuration.nix`.

This comes as an alternative to avoid **manually** (_imperative_ setup) initialize `lxd` when running for the first time, with:

```sh
lxd init

# or with pre-configured .yaml
lxd init --preseed < ./some-preseed-configuration.yaml
```

The proposed alternative will let `lxd` use the declared `virtualisation.lxd.preseed` options.  
It is declared in [`lxd` module in nixos `pkgs`](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/lxd.nix#L95).

### networking

Example is setup to run separated networks (bridges) as followed:

| profile    | interface       | gateway    | subnet mask       |
| ---------- | --------------- | ---------- | ----------------- |
| `default`  | lxdBrDefault    | 10.100.1.1 | 255.255.255.0 (8) |
| `dev`      | `lxdBrDev`      | 10.10.1.1  | 255.255.0.0 (16)  |
| `private0` | `lxdBrPrivate0` | 10.110.1.1 | 255.255.0.0 (16)  |

(subnetting may be tweaked here)

To view all existing `lxd` networks:

```sh
lxd network list
```

#### example convention

(to confirm)

| type    | network portion         | subnet mask example | example      |
| ------- | ----------------------- | ------------------- | ------------ |
| default | 10.100.1.x              | 255.255.255.0 (8)   | 10.100.1.10  |
|         |                         |                     | 10.100.1.100 |
|         |                         |                     |              |
| dev     | 10.10.x.x - 10.90.x.x   | 255.255.0.0 (16)    | 10.10.1.10   |
|         |                         |                     | 10.10.100.10 |
|         |                         |                     |              |
| private | 10.110.x.x - 10.190.x.x | 255.255.0.0 (16)    | 10.110.1.10  |
|         |                         |                     | 10.150.1.10  |

### storage

Similar to **networking**, each **profile** declares a dedicated `storage_pool`.  
The default location would be `/var/lib/lxd/storage-pools/${STORAGE_NAME}`.

---

---

# requirements

|       |         |
| ----- | ------- |
| nixos | `23.11` |

---

---

# setup

Example contains **3 profiles**:

- `default`: the default **profile** to use for any new containers
- `dev`: a dedicated **profile** for development, testing, etc...
- `private0`: a dedicated **profile** for private projects, work, etc...

Note:  
**profile** do not refer to **lxd profile** but a dedicated configuration for `lxd` containers with:

- `network`
- `storage_pool`
- `profile` (this is a **lxd profile** !)

### update `configuration.nix`

Copy files from `./lxd` directory to `/etc/nixos/` and import `lxd.nix` in `configuration.nix`:

```nix
# in /etc/nixos/configuration.nix (or dedicated module)
{
  imports = [
    ...
    /etc/nixos/lxd.nix
  ];

  ...
}
```

Then rebuild:

```sh
sudo nixos-rebuild switch
```

Verify if **storages**, **networks** and `lxd` **profiles** have been added correctly:

```sh
lxc network list && lxc storage list && lxc profile list
```

### add / edit **profiles**

**profiles** are located in `./lxd/profiles` (or `/etc/nixos/lxd/profiles` if already copied).

A basic profile would contain:

```nix
# ./some-profile.nix
{
  network = {
    // declare an interface to use
  };

  storage_pool = {
    // declare a storage, volume to use
  };

  profile = {
    // declare a `lxd` profile that refers `network` and `storage_pool`
  };
}
```

Declared variables in e.g `./some-profile.nix`, may be imported in `virtualisation.lxd.preseed` object (see `./lxd/lxd-preseed.nix`):

```nix
let
  SOME_PROFILE = (import ./profiles/default.nix);
in
{
  irtualisation.lxd.preseed =  {
    networks = [
     SOME_PROFILE.network
    ];

    profiles = [
     SOME_PROFILE.profile
    ];

    storage_pools = [
     SOME_PROFILE.storage_pool
    ];
  };
}
```

### networking

Additional netowrking configuration may be required (e.g forwarding, subnetting, etc).

To assign IP's (`ipv4`), following must be added to `./lxd/lxd-networking.nix` for each network:

```nix
networking.firewall.extraCommands = ''
  iptables -A INPUT -i ${NETWORK_NAME} -m comment --comment "lxd rule for ${NETWORK_NAME}" -j ACCEPT
'';
```

The default `eth0` device is used to bridge declared networked in `./lxd/profiles/${PROFILE_NAME}.nix`.  
This may be changed to another device though will require additional network configuration.

---

---

# containers

Defined **profiles** (as declaring `lxd` **profiles**) may then be used and refered to using the `--profile` flag.

### examples

A container may be created such as:

```sh
# profile:  default
# image:    ubuntu 22.04 server
lxc launch images:ubuntu/22.04 ubuntu-default --profile default

# profile:  dev
# image:    ubuntu 22.04 server
lxc launch images:ubuntu/22.04 ubuntu-dev --profile dev

# profile:  private0
# image:    ubuntu 22.04 server
lxc launch images:ubuntu/22.04 ubuntu-private0 --profile private0
```

---

---

# some useful commands

```sh
# view all containers
lxc list

# view a container config
lxc config show $CONTAINER_NAME --expanded

# start / stop a container
lxc start $CONTAINER_NAME
lxc stop $CONTAINER_NAME

# delete a container
lxc delete $CONTAINER_NAME

# multiple containers are supported within a command (`start`, `stop`, ...)
lxc start $CONTAINER_1_NAME $CONTAINER_2_NAME ...

#####

# list all networks
lxc network list

# list all storages
lxc storage list

# list all profiles
lxc profile list

###
# or all at once
lxc network list && lxc storage list && lxc profile list # && lxc list
```

---

# documentation & links

- https://discourse.nixos.org/t/howto-setup-lxd-on-nixos-with-nixos-guest-using-unmanaged-bridge-network-interface/21591
- https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/lxd.nix#L95
