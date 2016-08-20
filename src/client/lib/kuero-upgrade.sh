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

  # Detailed help message
  function _ku_cmd_help() {
    case $1 in

      'server')
        echo 'server has no option.'
        echo ''
        ;;

      'core')
        echo 'core has no option.'
        echo ''
        ;;

      *)
        echo "$1 does not exist!"
      ;;
    esac
    exit 1
  }

  # main
  case $1 in

    'server')
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Ask for a confirmation:
      while true; do
        read -p "Do you really want to upgrade the server? Please confirm [Y/n]?" yn
        case $yn in
          [Yy]* ) ssh ${user}@${server} "${KUERO_SRV} upgrade -n server"
                  break;;
          [Nn]* ) echo "Ok. The server won't be upgraded ...";
                  break;;
          * ) echo 'Please answer Yes or No.';;
        esac
      done
      ;;

    'core')
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Ask for a confirmation:
      while true; do
        read -p "Do you really want to upgrade the core container? Please confirm [Y/n]?" yn
        case $yn in
          [Yy]* ) ssh ${user}@${server} "${KUERO_SRV} upgrade -n core"
                  break;;
          [Nn]* ) echo "Ok. The core container won't be upgraded ...";
                  break;;
          * ) echo 'Please answer Yes or No.';;
        esac
      done
      ;;

    *)
      _ku_help
      ;;

  esac

}
