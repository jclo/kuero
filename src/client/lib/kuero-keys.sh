# Manage authentication keys.
_ku_cmd keys 'manage authentication keys'
function _ku_keys() {
  
  # Help message
  function _ku_keys_help() {
    echo ''
    echo 'Usage: kuero keys:COMMAND'
    echo ''
    echo 'add      #  add a key for the current user'
    echo 'clear    #  remove all authentication keys from the current user'
    echo 'remove   #  remove a key from the current user'
    echo ''
  }

  # main
  case $1 in

    'add')
      # Check if ~/.ssh/id_rsa.pub is here
      if [[ -f $HOME/.ssh/id_rsa.pub ]]; then
        echo 'Copying public key to server'
        # create .ssh dir if it doesn't exist, then copy key to .ssh/authorized_keys
        cat $HOME/.ssh/id_rsa.pub | ssh $KUERO_USER@$KUERO_SERVER 'mkdir -p .ssh && cat >> .ssh/authorized_keys && echo "Key copied"'
      else
        echo '~/.ssh/id_rsa.pub key do not exist!'
        echo 'Create one:'
        echo '  . ssh-keygen -t rsa -C "your_email@example.com"'
      fi
      ;;


    'clear')
      # Remove all the keys from .ssh/authorized_keys
        ssh $KUERO_USER@$KUERO_SERVER 'rm .ssh/authorized_keys && touch .ssh/authorized_keys'
        echo 'All the keys are removed.'
      ;;


    'remove')
      # Check if key credential provided
      if [[ $2 ]]; then
        # Ok, now check if it matches!
        if (ssh $KUERO_USER@$KUERO_SERVER grep -q "$2" .ssh/authorized_keys)
        then
          # Key found
          KEY_PATTERN="'/"${2}"/d'"
          ssh $KUERO_USER@$KUERO_SERVER sed -i ${KEY_PATTERN} .ssh/authorized_keys
          echo "Key with credential $2 removed."
        else
          # Key not found
          echo "There is no key with this credential $2."
        fi
      else
        echo 'You need to provide the credentials of your key!'
      fi
      ;;

    *)
      _ku_keys_help
      ;;

  esac

}

