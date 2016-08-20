# Nginx

`Nginx` isn't part of the standard Slackware packages. It must be built separately. The scripts required to build the `Nginx`packages are available on `www.slackbuilds.org`.

The package we use is slighlty different from the standard package. The folder `nginx.Slackbuilds` contains the modified script we use to create the package (nginx.SlackBuild-no-perl is the modified script while nginx.SlackBuild-dist is the default script).


## Nginx for a pure HTML/CSS/Javascript web app

The additional slackware packages required to build a Nginx HTTP server are detailed in the configuration file `../../server/kuero-srv.conf`.

The `nginx.conf` file is detailed in the folder `../html`.


### Run Nginx as a service

The `slackbuilds` provide a `rc.nginx` file.

You just need to add the following instructions to `/etc/rc.d/rc.local`:

    # Start Nginx server
    if [ -x /etc/rc.d/rc.nginx ]; then
      /etc/rc.d/rc.nginx start
    fi


## Nginx with PHP

The additional slackware packages required to build a Nginx HTTP server are detailed in the configuration file `../../server/kuero-srv.conf`.

The `nginx.conf` file is detailed in the folder `../php`.


### Configure `/etc/httpd/php.ini`:

The following lines should be commented:

    ;extension=curl.so
    ;extension=dba.so
    ;extension=enchant.so
    ;extension=gd.so
    ;extension=intl.so
    ;extension=ldap.so
    ;extension=pdo_sqlite.so
    ;extension=pspell.so
    ;extension=snmp.so

And the following line must be uncommented and completed to set the timezone:

    date.timezone = "Europe/Paris"


### Run Nginx as a service

You just need to add the following instructions to `/etc/rc.d/rc.local`:

    # Start php-fpm
    if [ -x /etc/rc.d/rc.rc.php-fpm ]; then
            /etc/rc.d/rc.rc.php-fpm start
    fi

    # Start Nginx server
    if [ -x /etc/rc.d/rc.nginx ]; then
            /etc/rc.d/rc.nginx start
    fi

#
