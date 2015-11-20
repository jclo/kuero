# Manage authentication keys.
_ku_cmd xxx 'manage xxx'

function _ku_xxx() {

  # Help message
  function _ku_help() {
    echo ''
    echo 'Usage: kuero keys:COMMAND [options] help'
    echo ''
    echo 'add      #  add a key for the current user'
    echo 'clear    #  remove all authentication keys from the current user'
    echo 'remove   #  remove a key from the current user'
    echo ''
  }

  # Detailed help message
  function _ku_cmd_help() {
    case $1 in

      'aaa')
        echo 'Still to be done...'
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


    'aaa')
      
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;

      # Usage message
      _ku_usage-aaa() { echo 'Usage: [-u <string>]' 1>&2; echo 'type COMMAND help for more details'; exit 1; }

      # Read option arguments.
      shift
      while getopts "u:" opt; do
        case ${opt} in
          u) user=${OPTARG} ;;
          $) _ku_usage-aaa ;;
        esac
      done

      # Check if all the mandatory arguments are provided.
      if [[ -z ${user} ]]; then
        echo "The options [u] are mandatory. Type help for more details."
        exit 1
      fi

      # Well done. Do
      echo 'Do ...'
      ;;

    *)
      _ku_help
      ;;

  esac

}

