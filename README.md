# Kuero

Kuero is a mini Heroku PaaS running inside a Virtual Machine. In a similar way, Kuero allows an user to push web applications from his client to Kuero server within a simple git command.

Kuero is built on top of [SpineOS](https://github.com/jclo/spineos), LXC Containers and Open vSwitch.

You can find more details on the architecture and how to use it at the address: http://kuero.mobilabs.fr


## How to build it

Copy the script `build.sh` and its configuration file `build.conf` inside a running SpineOS Virtual Machine:

```
cd /tmp
wget --no-check-certificate https://raw.github.com/jclo/kuero/<version>/build.sh
wget --no-check-certificate https://raw.github.com/jclo/kuero/<version>/build.conf
```

Then, launch the script:

```
chmod +x build.sh
./build.sh
```

The script installs and configures SpineOS to become a server of LXC containers. When, the installation is complete, you need to reboot the VM to complete the configuration. At the end of this second step, the VM is halted.

The credentails to login this new VM are:

```
root with the password 'kuero'
```

This password expires at the first login. You must to change it otherwise, the VM is locked.


## How to use it

The instructions to use this mini Heroku PaaS are available at the address: http://kuero/mobilabs/kuero-docOne.html


## License

LGPL.
