#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x
export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
export SSH_ENDPOINT="ssh_connect.py"
main(){
  if [ -z $NOREVERT ]; then  
    restart_ws_network
    revert_ws
    configure_nfs
  fi
}
restart_ws_network(){
  sudo vmware-networks --stop
  sudo vmware-networks --start
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

chmod +x $SSH_ENDPOINT

}

configure_nfs(){
  set -x
  create_ssh_endpoint
  source /home/jenkins/$FUEL_RELEASE-venv/bin/activate
  for esxi_host in $ESXI_HOSTS; do

    python2 $SSH_ENDPOINT $esxi_host $ESXI_USER $ESXI_PASSWORD 'storages=$(esxcli storage nfs list | grep nfs | cut -d" " -f1); for storage in $storages; do esxcli storage nfs remove -v $storage; done'
    echo "nfs storages have been successfully removed for $esxi_host"

    for nfs_share in $NFS_SHARES; do
      python2 $SSH_ENDPOINT $esxi_host $ESXI_USER $ESXI_PASSWORD "esxcli storage nfs add -H $NFS_SERVER -s /var/$nfs_share -v $nfs_share"
      echo "$nfs_share has been successfully connected for $esxi_host"
    done

    python2 $SSH_ENDPOINT $esxi_host $ESXI_USER $ESXI_PASSWORD 'esxcli storage core adapter rescan --all'
    echo "Rescan all datastores for $esxi_host"
  done

  for nfs_share in $NFS_SHARES; do
    sudo rm -rf "/var/$nfs_share/*"
  done

  [[ "${DEBUG}" == "true" ]] && set -x || set +x
}

main
