# Lxc

This folder contains the Lxc template patch required to build a minimalist version of Slackware running inside a Lxc Container.

This version has been validated with `Slackware64 14.2` and `Lxc 2.0.1`.

## Patch

`lxc-slackware` is the original template shipped with the Lxc package. `lxc-slackware-new` is the version needed for Kuero.

`lxc-slackware.patch` is the patch to apply to the distribution template.

The procedure to apply the patch is the following:

```
cd /usr/share/lxc/templates/
patch < lxc-slackware.patch
```

## Build

Then, you can build your lxc container with the command:
```
lxc-create -n {name} -t slackware
```

## Configure

Before you could run the container, you need to create a `cgroup` with:
```
mkdir /cgroup
```

## Bridge

`Lxc` can run with the classic `bridge-utils` bridge or with `OpenvSwitch`. There is the script `add-openvswitch.sh`, in the folder `servers`, that installs `OpenvSwitch` for `Lxc`.

If you prefer to uses the classical bridge, you need to install the `bridge-utils` package and add the following lines to `rc.local`. It creates the bridge during the boot process.
```
# Set bridge br0
brctl addbr br0
brctl setfd br0 0

/sbin/ifconfig br0 192.168.1.1 netmask 255.255.255.0 promisc up
```

## Run

Now you can start your container with the command:
```
lxc-start -n {name}
```

You can stop it with:
```
lxc-stop -n {name}
```

## Memory optimization with Btrfs

The script `add-lxc_container.sh` installs the containers on a Logical Volume formatted with Btrfs filesystem. Btrfs implements a mechanism CoW that prevents duplicating files. This is very useful for limiting the memory size required by a container.

If you want to benefit of this feature, you need to create a reference container with the option `Backingstore`:
```
lxc-create -n core -t slackware -B btrfs
```

Then you can derive a new container from this one with the command:
```
lxc-copy -s -n core -N myNewContainer
```

If you check the used memory size before and after cloning `core` you will notice almost no increase!


### Issue with `lxc-copy`

`lxc-copy` updates the name of the container in the file `config` but not in the file `/etc/HOSTNAME`. This should be done manually for the time being.


## Other issues

From 1.0, `Lxc` authorizes the container to exchange data with the host. This feature is enabled by adding the following line to the container fstab:
```
/hostDir  containerDir none bind,create=dir
```

`hostDir` is the absolute path to the host dir accessible to the container. `containerDir` is the relative path to `rootfs` of the container dir. `containerDir` has no  initial / because the path is relative to the container’s root.

the `fstab` file must be located at the root of the container (same as config and rootfs). If it is located at `rootfs/etc/fstab` it fails to mount `hostDir` inside the container!
