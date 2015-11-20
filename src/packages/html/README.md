# HTML Container

The HTML Container relies on the HTTP server `Nginx`. 

The slackware packages required to build this HTTP server are defined in the configuration file `../server/kuero-srv.conf`.

The `HTML web app` is defined in the same configuration file.

The URL of the server containing these binary packages is defined in `build.conf`.

The `Nginx` configuration file `nginx.conf` is defined in this folder.


## HTML web app

The HTML web app must be a Git repository compressed in the `txz` format (tar cfJ <archive.txz> <files>).
