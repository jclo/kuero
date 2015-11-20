# Manage containers
_ku_cmd vm 'manage containers'

function _ku_vm() {

  # Local variables
  local user=${KUERO_USER}
  local server=${KUERO_SERVER}
  
  # Is Server Up and am I root?
  _isRemoteServerHere
  _isAdmin


  # Help message
  function _ku_vm_help() {
    echo ''
    echo 'Usage: kuero vm:COMMAND [arg]'
    echo ''
    echo 'list     #  list the containers'
    echo 'info     #  provide info on a given container'
    echo 'create   #  create a new container'
    echo 'destroy  #  delete the container'
    echo 'start    #  start the container'
    echo 'stop     #  stop the container'
    echo 'update   #  update the container'
    echo ''
  }

  # main
  case $1 in

    'list')
      ssh ${user}@${server} 'lxc-ls'
      ;;

    'info')
      #if [[ $2 ]]; then
        #ssh $KUERO_USER@$KUERO_SERVER "lxc-info -n $2"
      #else
        # Container name not provided!
        #echo 'You need to provide a container name!'
      #fi
      shift
      ssh ${user}@${server} "${KUERO_SRV_VM} info $@"
      ;;

    'create')
      shift
      ssh ${user}@${server} "${KUERO_SRV_VM} create $@"
      ;;

    'destroy')
      shift
      ssh  ${user}@${server} "${KUERO_SRV_VM} destroy $@"
      ;;

    'start')
      shift
      ssh  ${user}@${server} "${KUERO_SRV_VM} start $@"
      ;;

    'stop')
      shift
      ssh  ${user}@${server} "${KUERO_SRV_VM} stop $@"
      ;;

    'update')
      shift
      ssh  ${user}@${server} "${KUERO_SRV_VM} update $@"
      ;;

    *)
      _ku_vm_help
      ;;

  esac

}

