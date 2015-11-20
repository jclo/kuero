# PHP Container

The PHP Container relies on the HTTP server `Nginx`. 

The slackware packages required to build this HTTP server are defined in the configuration file `../server/kuero-srv.conf`.

The `PHP web app` is defined in the same configuration file.

The URL of the server containing these binary packages is defined in `build.conf`.

The `Nginx` configuration file `nginx.conf` is defined in this folder.


## PHP web app

The PHP web app must be a Git repository compressed in the `txz` format (tar cfJ <archive.txz> <files>).
