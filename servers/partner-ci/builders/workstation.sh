#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  fuel_release=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
  export FUEL_RELEASE=$fuel_release
fi

if [[ $ISO_FILE == *"custom"* ]]; then
  export FUEL_RELEASE=90
fi

[[ "${UPDATE_MASTER}" == "true" ]] && export ISO_VERSION='mos-mu' || export ISO_VERSION='mos'
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"
export SSH_ENDPOINT="ssh_connect.py"
main(){
  if [[ "${WS_NOREVERT}" == "false" ]]; then
    restart_ws_network
    revert_ws
    configure_nfs
  fi
}
restart_ws_network(){
  sudo vmware-networks --stop
  if sudo vmware-networks --start; then
    echo "successful networks-restart "
  else
    echo "WARNING you need to check configuration of vmnet adapters on this lab"
    exit 1
  fi
}

# waiting for ending of parallel processes
wait_ws() {
  while [ $(pgrep vmrun | wc -l) -ne 0 ] ; do sleep 5; done
}

revert_ws() {
  set +x

  cmd="vmrun -T ws-shared -h https://localhost:443/sdk \
       -u ${WORKSTATION_USERNAME} -p ${WORKSTATION_PASSWORD}"
  nodes=${WORKSTATION_NODES}
  snapshot="${WORKSTATION_SNAPSHOT}"

  # Check that vms are exist
  for node in $nodes; do
    $cmd listRegisteredVM | grep -q $node || \
      { echo "Error: $node does not exist or does not registered"; exit 1; }
  done

  # reverting in parallel
  for node in $nodes; do
    echo "Reverting $node to $snapshot"
    $cmd revertToSnapshot "[standard] $node/$node.vmx" $snapshot || \
      { echo "Error: reverting of $node has failed";  exit 1; } &
  done

  wait_ws

  # start from saved state
  for node in $nodes; do
    echo "Starting $node"
    $cmd start "[standard] $node/$node.vmx" || \
      echo "Error: $node failed to start" &
  done

  wait_ws

  [[ "${DEBUG}" == "true" ]] && set -x || set +x
}

create_ssh_endpoint(){

cat << CONTENT > $SSH_ENDPOINT
#!/usr/bin/python2
import paramiko
import sys

host = sys.argv[1]
user = sys.argv[2]
secret = sys.argv[3]
command = sys.argv[4]
port = 22

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(hostname=host, username=user, password=secret, port=port)
stdin, stdout, stderr = client.exec_command(command)
data = stdout.read() + stderr.read()
print data
client.close()
CONTENT

sudo chmod +x $SSH_ENDPOINT

}

esxi_exec(){

  set -x
  host=$1
  cmd=$2
  echo "$cmd-------------------------------------------------------"
  python2 $SSH_ENDPOINT $host $ESXI_USER $ESXI_PASSWORD "$cmd"

}
configure_nfs(){
  set -x
  create_ssh_endpoint
  source $VENV_PATH/bin/activate
  for esxi_host in $ESXI_HOSTS; do
    esxi_exec $esxi_host './sbin/services.sh restart'
    esxi_exec $esxi_host '/etc/init.d/sfcbd-watchdog stop; rm -rf /var/run/sfcb/*;/etc/init.d/sfcbd-watchdog start'
    esxi_exec $esxi_host 'esxcli network firewall set --enabled false'
    esxi_exec $esxi_host 'esxcli system hostname get'
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    if [[ ${DEBUG} == "true" ]]; then
      esxi_exec $esxi_host 'esxcli storage nfs list'
      echo "----------------------------------------------------------------------------------------------------"
    fi
    esxi_exec $esxi_host 'storages=$(esxcli storage nfs list | grep nfs | cut -d" " -f1); for storage in $storages; do esxcli storage nfs remove -v $storage; done'

    for nfs_share in $NFS_SHARES; do
      if esxi_exec $esxi_host "esxcli storage nfs add -H $NFS_SERVER -s /var/$nfs_share -v $nfs_share"; then
        echo "$nfs_share has been successfully connected for $esxi_host"
      else
        echo "there is trouble with $nfs_share, please check vmware configurations"; exit 1;
      fi
    done

    esxi_exec $esxi_host 'esxcli storage core adapter rescan --all'

  done

  if [[ "${NFS_CLEAN}" == "true" ]]; then
    for nfs_share in $NFS_SHARES; do
      sudo rm -rf "/var/$nfs_share/*"
    done
  fi

  [[ "${DEBUG}" == "true" ]] && set -x || set +x
}

main
