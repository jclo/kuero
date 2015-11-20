# Manage authentication keys.
_ku_cmd config 'manage configuration'

function _ku_config() {

  # Help message
  function _ku_help() {
    echo ''
    echo 'Usage: kuero keys:COMMAND [options] help'
    echo ''
    echo 'list     #  list configuration parameters'
    echo 'user     #  set the username'
    echo 'server   #  set the servername'
    echo ''
  }

  # Detailed help message
  function _ku_cmd_help() {
    case $1 in

      'list')
        echo 'list has no option.'
        echo ''
        ;;

      'user')
        echo 'Usage: [-u <string>]'
        echo '-u   username for the connection to the server'
        echo ''
        ;;

      'server')
        echo 'Usage: [-n <string>]'
        echo '-n   domain name or IP address of the server'
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

    'list')
      # List has no option
      echo "username: ${KUERO_USER}"
      echo "server: ${KUERO_SERVER}"
      echo "version: ${VERSION}"
      ;;


    'user')  
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Usage message
      _ku_usage-user() { echo 'Usage: [-u <string>]' 1>&2; echo 'type COMMAND help for more details'; exit 1; }

      # Read option arguments.
      shift
      while getopts "u:" opt; do
        case ${opt} in
          u) user=${OPTARG} ;;
          $) _ku_usage-user ;;
        esac
      done

      # Check if all the mandatory arguments are provided.
      if [[ -z ${user} ]]; then
        echo "The options [u] are mandatory. Type help for more details."
        exit 1
      fi

      # Well done. Proceed!
      # To comply with both BSD and Linux (sed -i behaves differently on BSD and Linux)
      sed 's/^.*KUERO_USER.*$/KUERO_USER='"${user}"'/' ${CONFIGFILE} > ${CONFIGFILE}_2
      mv ${CONFIGFILE}_2 ${CONFIGFILE}
      ;;


    'server')
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Usage message
      _ku_usage-server() { echo 'Usage: [-n <string>]' 1>&2; echo 'type COMMAND help for more details'; exit 1; }

      # Read option arguments.
      shift
      while getopts "n:" opt; do
        case ${opt} in
          n) server=${OPTARG} ;;
          $) _ku_usage-server ;;
        esac
      done

      # Check if all the mandatory arguments are provided.
      if [[ -z ${server} ]]; then
        echo "The options [n] are mandatory. Type help for more details."
        exit 1
      fi

      # Well done. Proceed!
      # To comply with both BSD and Linux (sed -i behaves differently on BSD and Linux)
      sed 's/^.*KUERO_SERVER.*$/KUERO_SERVER='"${server}"'/' ${CONFIGFILE} > ${CONFIGFILE}_2
      mv ${CONFIGFILE}_2 ${CONFIGFILE}
      ;;


    *)
      _ku_help
      ;;

  esac

}

