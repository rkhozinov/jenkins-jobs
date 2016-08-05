#Set statistics job-group properties for tests
export FUEL_STATS_HOST=${FUEL_STATS_HOST:-"fuel-collect-systest.infra.mirantis.net"}
export ANALYTICS_IP="${ANALYTICS_IP:-"fuel-stats-systest.infra.mirantis.net"}"
export MIRROR_HOST=${MIRROR_HOST:-"mirror.seed-cz1.fuel-infra.org"}

[ ${SNAPSHOTS_ID} ] && export SNAPSHOTS_ID=${SNAPSHOTS_ID} || export SNAPSHOTS_ID=${CUSTOM_VERSION:10}
[ -z "${SNAPSHOTS_ID}" ] && { echo SNAPSHOTS_ID is empty; exit 1; }

wget --no-check-certificate -O snapshots.params ${SNAPSHOTS_URL/SNAPSHOTS_ID/$SNAPSHOTS_ID}

[ -f snapshots.params ] &&  . snapshots.params || \
  { echo snapshots.params file is not found; exit 1; }

if [[ "${UPDATE_MASTER}" == "true" ]]; then
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

cat << UPDATE_PROPERTIES > update.properties
SNAPSHOTS_ID=$SNAPSHOTS_ID
MIRROR_UBUNTU=$MIRROR_UBUNTU
UPDATE_FUEL_MIRROR=$UPDATE_FUEL_MIRROR
UPDATE_MASTER=$UPDATE_MASTER
EXTRA_RPM_REPOS=$EXTRA_RPM_REPOS
EXTRA_DEB_REPOS=$EXTRA_DEB_REPOS
UPDATE_PROPERTIES

[[ "${UPDATE_MASTER}" == "true" ]] && cat snapshots.params >> update.properties;

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=${SNAPSHOTS_ID}
SNAPSHOTS_ID=${SNAPSHOTS_ID}
ISO_FILE=$ISO_FILE
TEST_GROUP=$TEST_GROUP
TEST_GROUP_CONFIG=$TEST_GROUP_CONFIG
TEST_JOB_NAME=$JOB_NAME
TEST_JOB_BUILD_NUMBER=$BUILD_NUMBER
PKG_JOB_BUILD_NUMBER=$PKG_JOB_BUILD_NUMBER
PLUGIN_VERSION=$PLUGIN_VERSION
TREP_TESTRAIL_SUITE=$TREP_TESTRAIL_SUITE
TREP_TESTRAIL_SUITE_DESCRIPTION=$TREP_TESTRAIL_SUITE_DESCRIPTION
TREP_TESTRAIL_PLAN=$TREP_TESTRAIL_PLAN
TREP_TESTRAIL_PLAN_DESCRIPTION=$TREP_TESTRAIL_PLAN_DESCRIPTION
DATE=$(date +'%B-%d')
REPORTER_PROPERTIES

source "${VENV_PATH}/bin/activate"

#/btsync/tpi_systest_mod.sh -d ${OPENSTACK_RELEASE} \
#                           -n "${NODES_COUNT}" \
#                           -i ${ISO_PATH} \
#                           -t "${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})" \
#                           $systest_parameters

#/btsync/tpi_systest_mod2.sh -d ${OPENSTACK_RELEASE} \
#                            -i ${ISO_PATH} \
#                            -t "${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})" \
#                            $systest_parameters


main() {

  #clean_old_bridges

  if [ -z $NOREVERT ]; then  
    restart_ws_network
    revert_ws "$WORKSTATION_NODES"
    configure_nfs
    clean_iptables
  fi

  rm -rf logs/*

  #Run test in background and wait before environment is created
  echo sh -x "utils/jenkins/system_tests.sh" -t test $systest_parameters -i "${ISO_PATH}" -o --group=$TEST_GROUP
  sh -x "utils/jenkins/system_tests.sh" \
      -t test $systest_parameters \
      -i "${ISO_PATH}" \
      -o --group="${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})" &

  export SYSTEST_PID=$!

  #Wait before environment is created
  while [ $(virsh net-list | grep $ENV_NAME | wc -l) -ne 5 ]; do 
    sleep 10 
    if ! ps -p $SYSTEST_PID > /dev/null
    then
      echo System tests exited prematurely, aborting
      exit 1
    fi
  done
  sleep 5 

  add_interface_to_bridge $ENV_NAME private vmnet2

  echo waiting for system tests to finish
  wait $SYSTEST_PID
  export RES=$?
  echo ENVIRONMENT NAME is $ENV_NAME

  virsh net-dumpxml "${ENV_NAME}_admin" | grep -P "(\d+\.){3}" -o | awk '{print "Fuel master node IP: "$0"2"}'

  echo Result is $RES
  if [ $RES -eq 0 ]; then
    echo Tests succeeded
  fi

  [ "$ERASE_ENV_AFTER" == "true" ] && { echo Erasing $ENV_NAME; dos.py erase $ENV_NAME; }
  #[ "$REVERT_AFTER" == "true" ] &&  { revert_ws "$WORKSTATION_NODES" }
}

restart_ws_network(){
    sudo vmware-networks --stop
    sudo vmware-networks --start
}

kill_test(){
    pid=$1
    if [ ! -z $pid ]; then
        echo "killing $pid and its childs" && pkill --parent $pid && kill $pid && exit 1;

    elif [ -z $SYSTEST_PID ]; then
        echo "killing $pid and its childs" && pkill --parent $pid && kill $pid && exit 1;

    else
        echo "test process id doesn't exist"
        exit 1
    fi 
}

add_interface_to_bridge() {
  env=$1
  net_name=$2
  nic=$3  
  ip=$4

  for net in $(virsh net-list | grep ${env}_${net_name} | awk '{print $1}'); do
    bridge=$(virsh net-info $net | grep -i bridge |awk '{print $2}')
    setup_bridge $bridge $nic $ip && echo $net_name bridge $bridge ready
  done
}

setup_bridge() {
  bridge=$1
  nic=$2

  sudo brctl stp $bridge off
  sudo brctl addif $bridge $nic

  sudo ip address flush $nic
  sudo ip link set dev $nic up
  sudo ip link set dev $bridge up

  if sudo /sbin/iptables-save | grep $bridge | grep -i reject | grep -q FORWARD; then
    sudo /sbin/iptables -D FORWARD -o $bridge -j REJECT --reject-with icmp-port-unreachable
    sudo /sbin/iptables -D FORWARD -i $bridge -j REJECT --reject-with icmp-port-unreachable
  fi
}

clean_old_bridges() {
  for intf in $EXT_IFS; do
    for br in $(/sbin/brctl show | grep -v "bridge name" | cut -f1 -d'	'); do
        brctl show $br | grep -q $intf && \
          sudo brctl delif $br $intf  && \
          echo $intf deleted from $br
    done
  done
}

clean_iptables() {
  sudo /sbin/iptables -F
  sudo /sbin/iptables -t nat -F
  sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

revert_ws() {
  cmd="vmrun -T ws-shared -h https://localhost:443/sdk -u ${WORKSTATION_USERNAME} -p ${WORKSTATION_PASSWORD}"
  for i in $1; do
    $cmd listRegisteredVM | grep -q $i || { echo "VM $i does not exist"; exit 1; }
    echo vmrun: reverting $i to $WORKSTATION_SNAPSHOT 
    $cmd revertToSnapshot "[standard] $i/$i.vmx" $WORKSTATION_SNAPSHOT && echo "vmrun: $i reverted" || { echo "Error: revert of $i failed";  exit 1; }
    echo vmrun: starting $i 
    $cmd start "[standard] $i/$i.vmx" && echo "vmrun: $i is started" || { echo "Error: $i failed to start";  exit 1; }
  done
}

create_ssh_endpoint(){

cat << SSH_ENDPOINT > $SSH_ENDPOINT
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
SSH_ENDPOINT

chmod +x $SSH_ENDPOINT

}

configure_nfs(){
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
}

main

exit $RES
