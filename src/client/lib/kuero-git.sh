# Manage authentication keys.
_ku_cmd git 'manage projects'

function _ku_git() {

  # Local variables
  local user=${KUERO_USER}
  local server=${KUERO_SERVER}
  local basedir=${BASEDIR}

  # Is Server Up and am I end user?
  # Exist if I am root.
  _isRemoteServerHere
  _isRoot

  # Help message
  function _ku_help() {
    echo ''
    echo 'Usage: kuero git:COMMAND [options] help'
    echo ''
    echo 'clone    #  clone remote git on local host'
    echo 'list     #  list the git remote repositories'
    echo 'push     #  push local git project on remote git server'
    echo ''
  }

  # Detailed help message
  function _ku_cmd_help() {
    case $1 in

      'clone')
        echo 'Usage: [-n <string>]'
        echo '-n   name of the git remote repository'
        echo ''
        ;;

      'list')
        echo 'list has no option.'
        echo ''
        ;;

      'push')
        echo 'Usage: [-n <string>]'
        echo '-n   name of the git remote repository'
        ;;

      *)
        echo "$1 does not exist!"
      ;;
    esac
    exit 1
  }


  # main
  case $1 in

    'clone')  
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Usage message
      _ku_usage-clone() { echo 'Usage: [-n <string>]' 1>&2; echo 'type COMMAND help for more details'; exit 1; }

      # Read option arguments.
      shift
      while getopts "n:" opt; do
        case ${opt} in
          n) gitname=${OPTARG} ;;
          $) _ku_usage-clone ;;
        esac
      done

      # Check if all the mandatory arguments are provided.
      if [[ -z ${gitname} ]]; then
        echo "The options [n] are mandatory. Type help for more details."
        exit 1
      fi

      # Well done. Proceed!
      # Ok, check if git project already exists
      if (ssh ${user}@${server} test -d ${gitname})
      then
        # Ok, it exists, clone it.
        cd ${basedir} && git clone ${user}@${server}:~/${gitname}
      else
        echo 'Git repository does not exist!'
      fi
      ;;


    'list')
      ssh ${user}@${server} 'ls -l | grep "^d"'
      ;;


    'push')
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Usage message
      _ku_usage-push() { echo 'Usage: [-n <string>]' 1>&2; echo 'type COMMAND help for more details'; exit 1; }

      # Read option arguments.
      shift
      while getopts "n:" opt; do
        case ${opt} in
          n) gitname=${OPTARG} ;;
          $) _ku_usage-clone ;;
        esac
      done

      # Check if all the mandatory arguments are provided.
      if [[ -z ${gitname} ]]; then
        echo "The options [n] are mandatory. Type help for more details."
        exit 1
      fi

      # Well done. Proceed!
      # Check if remote git exists.
        if (ssh ${user}@${server} test -d ${gitname})
        then
          # push it.
          # Push to server first.
          cd ${basedir} && git push ${user}@${server}:~/${gitname} master
          # Push to vm then.
          ssh ${user}@${server} "${KUERO_SRV_USR} push -u ${user} -n ${gitname}"
        else
          echo "Git repository ${gitname} does not exist!"
        fi
      ;;


    *)
      _ku_help
      ;;

  esac

}

