# Upgrade Server and Core container packages.
_ku_cmd upgrade 'upgrade the server or the core container'

function _ku_upgrade() {

  # Local variables
  local user=${KUERO_USER}
  local server=${KUERO_SERVER}
  
  # Is Server Up and am I root?
  _isRemoteServerHere
  _isAdmin


  # Help message
  function _ku_help() {
    echo ''
    echo 'Usage: kuero upgrade:COMMAND [options] help'
    echo ''
    echo 'server   #  upgrade the server'
    echo 'core     #  upgrade the core container'
    echo ''
  }

  # main
  case $1 in

    'server')
      ssh ${user}@${server} "${KUERO_SRV} upgrade -n server"
      ;;

    'core')
      ssh ${user}@${server} "${KUERO_SRV} upgrade -n core"
      ;;

    *)
      _ku_help
      ;;

  esac

}

