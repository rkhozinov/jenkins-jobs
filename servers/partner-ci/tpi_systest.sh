#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

export SSH_ENDPOINT="ssh_connect.py"
prepare_ws(){
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

if [[ "${UPDATE_MASTER}" == "true" ]]; then
  #Set statistics job-group properties for tests
  export FUEL_STATS_HOST=${FUEL_STATS_HOST:-"fuel-collect-systest.infra.mirantis.net"}
  export ANALYTICS_IP="${ANALYTICS_IP:-"fuel-stats-systest.infra.mirantis.net"}"
  export MIRROR_HOST=${MIRROR_HOST:-"mirror.seed-cz1.fuel-infra.org"}
  
  [ ${SNAPSHOTS_ID}      ] && export SNAPSHOTS_ID=${SNAPSHOTS_ID} || export SNAPSHOTS_ID=${CUSTOM_VERSION:10}
  [ -z "${SNAPSHOTS_ID}" ] && export SNAPSHOTS_ID='lastSuccessfulBuild'
  
  wget --no-check-certificate -O snapshots.params ${SNAPSHOTS_URL/SNAPSHOTS_ID/$SNAPSHOTS_ID}
  
  [ -f snapshots.params ] &&  . snapshots.params || \
    { echo snapshots.params file is not found; exit 1; }
  
  if [[ ! "${MIRROR_UBUNTU}" ]]; then
      case "${UBUNTU_MIRROR_ID}" in
          latest)
              UBUNTU_MIRROR_URL="$(curl "http://${MIRROR_HOST}/pkgs/ubuntu-latest.htm")"
              ;;
          *)
              UBUNTU_MIRROR_URL="http://${MIRROR_HOST}/pkgs/${UBUNTU_MIRROR_ID}/"
      esac

      UBUNTU_REPOS="deb ${UBUNTU_MIRROR_URL} trusty main universe multiverse|deb ${UBUNTU_MIRROR_URL} trusty-updates main universe multiverse|deb ${UBUNTU_MIRROR_URL} trusty-security main universe multiverse"
  
      ENABLE_PROPOSED="${ENABLE_PROPOSED:-true}"
  
      if [ "$ENABLE_PROPOSED" = true ]; then
          UBUNTU_PROPOSED="deb ${UBUNTU_MIRROR_URL} trusty-proposed main universe multiverse"
          UBUNTU_REPOS="$UBUNTU_REPOS|$UBUNTU_PROPOSED"
      fi
      export MIRROR_UBUNTU="$UBUNTU_REPOS"
  fi
  
  function join() {
      local __sep="${1}"
      local __head="${2}"
      local __tail="${3}"
      [[ -n "${__head}" ]] && echo "${__head}${__sep}${__tail}" || echo "${__tail}"
  }
  
  function to_uppercase() {
      echo "$1" | awk '{print toupper($0)}'
  }
  
  __space=' '
  __pipe='|'
  
  # Adding MOS rpm repos to
  # - UPDATE_FUEL_MIRROR - will be used for master node
  # - EXTRA_RPM_REPOS - will be used for nodes in cluster
  for _dn in  "os"        \
              "proposed"  \
              "updates"   \
              "holdback"  \
              "hotfix"    \
              "security"  ; do
      # a pointer to variable name which holds value of enable flag for this dist name
      __enable_ptr="ENABLE_MOS_CENTOS_$(to_uppercase "${_dn}")"
      if [[ "${!__enable_ptr}" = true ]] ; then
          # a pointer to variable name which holds repo id
          __repo_id_ptr="MOS_CENTOS_$(to_uppercase "${_dn}")_MIRROR_ID"
          __repo_url="http://${MIRROR_HOST}/mos-repos/centos/mos9.0-centos7/snapshots/${!__repo_id_ptr}/x86_64"
          __repo_name="mos-${_dn},${__repo_url}"
          UPDATE_FUEL_MIRROR="$(join "${__space}" "${UPDATE_FUEL_MIRROR}" "${__repo_url}" )"
          EXTRA_RPM_REPOS="$(join "${__pipe}" "${EXTRA_RPM_REPOS}" "${__repo_name}" )"
      fi
  done
  
  # Adding MOS deb repos to
  # - EXTRA_DEB_REPOS - will be used for nodes in cluster
  for _dn in  "proposed"  \
              "updates"   \
              "holdback"  \
              "hotfix"    \
              "security"  ; do
      # a pointer to variable name which holds value of enable flag for this dist name
      __enable_ptr="ENABLE_MOS_UBUNTU_$(to_uppercase "${_dn}")"
      # a pointer to variable name which holds repo id
      __repo_id_ptr="MOS_UBUNTU_MIRROR_ID"
      __repo_url="http://${MIRROR_HOST}/mos-repos/ubuntu/snapshots/${!__repo_id_ptr}"
      if [[ "${!__enable_ptr}" = true ]] ; then
          __repo_name="mos-${_dn},deb ${__repo_url} mos9.0-${_dn} main restricted"
          EXTRA_DEB_REPOS="$(join "${__pipe}" "${EXTRA_DEB_REPOS}" "${__repo_name}")"
      fi
  done
  
  export UPDATE_FUEL_MIRROR   # for fuel-qa
  export UPDATE_MASTER        # for fuel-qa
  export EXTRA_RPM_REPOS      # for fuel-qa
  export EXTRA_DEB_REPOS      # for fuel-qa
fi 

export TCPDUMP_PID
export TCPDUMP_PID2

[ -z $ISO_FILE           ] && { echo "ISO_FILE variable is empty"; exit 1; }
[ -z $PLUGIN_VERSION     ] && { echo "PLUGIN_VERSION is not defined"; exit 1; } 
[ -z $DVS_PLUGIN_VERSION ] && { echo "DVS_PLUGIN_VERSION is empty"; exit 1; }

#remove old logs and test data
[ -f nosetest.xml ] && sudo rm -f nosetests.xml
sudo rm -rf logs/*

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"

[ ! -f $ISO_PATH ] && { echo "ISO_FILE is not found"; exit 1; }

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
fi


if [[ "${UPDATE_MASTER}" == "true" ]]; then
  export ENV_NAME="${ENV_PREFIX}.${SNAPSHOTS_ID}"
else 
  export ENV_NAME="${ENV_PREFIX}"
fi

export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[ -z "${WORKSPACE}"       ] && export WORKSPACE=$(pwd)
[ -z "${DVS_PLUGIN_PATH}" ] && export DVS_PLUGIN_PATH=$(ls -t ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm | head -n 1)
[ -z "${DVS_PLUGIN_PATH}" ] && { echo "DVS_PLUGIN_PATH is empty"; exit 1; }
[ -z "${PLUGIN_PATH}"     ] && export PLUGIN_PATH=$DVS_PLUGIN_PATH

[ -z $TEST_GROUP_PREFIX ] && { echo "testgroup prefix is empty"; exit 1; } || echo test-group-prefix: $TEST_GROUP_PREFIX

echo "test-group: ${TEST_GROUP}"
echo "env-name: ${ENV_NAME}"
echo "use-snapshots: ${USE_SNAPSHOTS}"
echo "fuel-release: ${FUEL_RELEASE}"
echo "venv-path: ${VENV_PATH}"
echo "env-name: ${ENV_NAME}"
echo "iso-path: ${ISO_PATH}"
echo "plugin-path: ${DVS_PLUGIN_PATH}"
echo "plugin-checksum: $(md5sum -b ${DVS_PLUGIN_PATH})"

source "${VENV_PATH}/bin/activate"

add_interface_to_bridge() {
  env=$1
  net_name=$2
  nic=$3  

  for net in $(virsh net-list | grep ${env}_${net_name} | awk '{print $1}'); do
    bridge=$(virsh net-info $net | grep -i bridge |awk '{print $2}')
    setup_bridge $bridge $nic && echo $net_name bridge $bridge ready
  done
}

setup_bridge() {
  set -x 
  bridge=$1
  nic=$2

  [[ "${DISABLE_STP}" == "true" ]] && sudo brctl stp $bridge off
  sudo brctl addif $bridge $nic

  sudo ip address flush $nic
  sudo ip link set dev $nic up
  sudo ip link set dev $bridge up

  if sudo /sbin/iptables-save | grep $bridge | grep -i reject | grep -q FORWARD; then
    sudo /sbin/iptables -D FORWARD -o $bridge -j REJECT --reject-with icmp-port-unreachable
    sudo /sbin/iptables -D FORWARD -i $bridge -j REJECT --reject-with icmp-port-unreachable
  fi

  if [[ "${DEBUG}" == "true" ]]; then
    sudo brctl show
    sudo brctl show $bridge
    sudo ip link 
    sudo ip address 
    sudo ip address show $nic
    sudo iptables -L -v -n
    sudo iptables -t nat -L -v -n
  fi
  
}

clean_iptables() {
  sudo /sbin/iptables -F
  sudo /sbin/iptables -t nat -F
  sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

#sh -x "utils/jenkins/system_tests.sh" \
#    -k \
#    -K \
#    -t test \
#    -i "${ISO_PATH}" \
#    -o --group="${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})" &

prepare_ws

export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}${WORKSPACE}"
echo ${PYTHONPATH}

python run_system_test.py run -q --nologcapture --with-xunit "${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})"
export SYSTEST_PID=$!

#Wait before environment is created
while [ true ]; do 
  [ $(virsh net-list | grep $ENV_NAME | wc -l) -eq 5 ] && break || sleep 10
  [ -e /proc/$SYSTEST_PID ] && continue || \
    { echo System tests exited prematurely, aborting; exit 1; }
done

[[ "${CLEAN_IPTABLES}" == "true" ]] && clean_iptables

add_interface_to_bridge $ENV_NAME private vmnet2
add_interface_to_bridge $ENV_NAME private vmnet3

if [[ "${DEBUG}" == "true" ]]; then 
  rm -rf vmnet2.dump
  rm -rf vmnet3.dump
  sudo tcpdump -i vmnet2 -w vmnet2.pcap &
  export TCPDUMP_PID=$!
  sudo tcpdump -i vmnet3 -w vmnet3.pcap &
  export TCPDUMP_PID2=$!
fi

echo "Waiting for system tests to finish"
wait $SYSTEST_PID
export RESULT=$?
[[ "${DEBUG}" == "true" ]] && { sudo kill -SIGTERM $TCPDUMP_PID; sudo kill -SIGTERM $TCPDUMP_PID; }

echo "ENVIRONMENT NAME is $ENV_NAME"
virsh net-dumpxml "${ENV_NAME}_admin" | grep -P "(\d+\.){3}" -o | awk '{print "Fuel master node IP: "$0"2"}'

[ $RESULT -eq 0 ] && { echo "Tests succeeded"; exit $RESULT; }

