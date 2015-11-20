# Manage the users
_ku_cmd users 'manage users'

function _ku_users() {

  # Local variables
  local user=${KUERO_USER}
  local server=${KUERO_SERVER}

  # Is Server Up and am I root?
  _isRemoteServerHere
  _isAdmin


  # Help message
  function _ku_help() {
    echo ''
    echo 'Usage: kuero users:COMMAND [options] help'
    echo ''
    echo 'list     #  list the user accounts'
    echo 'add      #  add a new user'
    echo 'remove   #  delete the user'
    echo ''
  }

  # Detailed help message
  function _ku_cmd_help() {
    case $1 in

      'list')
        echo 'list has no option.'
        echo ''
        ;;

      'add')
        echo 'Usage: [-n <string>]'
        echo '-u   username'
        echo ''
        ;;

      'remove')
        echo 'Usage: [-n <string>]'
        echo '-u   username'
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
      ssh ${user}@${server} "cat /etc/passwd | awk -F ':' '\$3>=1000 {print \$1, \$6}' "
      ;;

    'add')
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Usage message
      _ku_usage-add() { echo 'Usage: [-u <string>]' 1>&2; echo 'type COMMAND help for more details'; exit 1; }

      # Read option arguments.
      shift
      while getopts "u:" opt; do
        case ${opt} in
          u) username=${OPTARG} ;;
          $) _ku_usage-add ;;
        esac
      done

      # Check if all the mandatory arguments are provided.
      if [[ -z ${username} ]]; then
        echo "The options [u] are mandatory. Type help for more details."
        exit 1
      fi

      # Well done. Proceed!
      # Check if this username is new.
      if ! (ssh ${user}@${server} id -u ${username} &> /dev/null)
      then
        # Ok this user doesn't exist. We can add it.
        ssh ${user}@${server} useradd -m -d /home/${username} ${username}
        # Create a random password using Remote Server to avoid Linux, BSD unconsistencies
        KU_PASS=$(ssh ${user}@${server} '< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c8')
        # Add password to ${username}
        ssh ${user}@${server} "echo ${username}:$KU_PASS | chpasswd"
        echo "User ${username} created with password $KU_PASS"
        # Generate key
        KEY_GEN='su '${username}' -c '\''ssh-keygen -t rsa -N "" -n '${username}' -f /home/'${username}'/.ssh/id_rsa'\'
        echo $KEY_GEN
        ssh ${user}@${server} $KEY_GEN &> /dev/null
      else
        echo "${username} user already exist!"
        exit 1
      fi
      ;;

    'remove')
      if [[ $2 == 'help' ]]; then _ku_cmd_help $1; fi;
      # Usage message
      _ku_usage-remove() { echo 'Usage: [-u <string>]' 1>&2; echo 'type COMMAND help for more details'; exit 1; }

      # Read option arguments.
      shift
      while getopts "u:" opt; do
        case ${opt} in
          u) username=${OPTARG} ;;
          $) _ku_usage-remove ;;
        esac
      done

      # Check if all the mandatory arguments are provided.
      if [[ -z ${username} ]]; then
        echo "The options [u] are mandatory. Type help for more details."
        exit 1
      fi

      # Well done. Proceed!
      # Check if vm are associated to this user.
      if (ssh ${user}@${server} "lxc-ls | grep -q "${username}_*"")
      then
        echo "Containers exist for the user ${username}. Delete them first."
        exit 1
      fi

      # Check if this user exists.
      if (ssh ${user}@${server} id -u ${username} &> /dev/null)
      then
      # Ok. Ask for confirmation before deleting it.
      while true; do
        read -p "This will delete ${username} account, home dir and mail spool. Please confirm [Y/n]?" yn
        case $yn in
          [Yy]* ) ssh  ${user}@${server} "userdel -r ${username}";
                  echo "${username} account deleted."
                  break;;
          [Nn]* ) echo 'Aborting ...';
                  echo ' ';
                  exit 0;
                  break;;
          * ) echo 'Please answer Yes or No.';;
        esac
      done
      echo ' '
      else
        echo "${username} user does not exist!"
        exit 1
      fi
      ;;

    *)
      _ku_help
      ;;

  esac

}

