#!/bin/bash

set -x

LOG=tpi_systest.log
JENKINS_URL="http://jenkins-product.srt.mirantis.net:8080/"

# MU1 update
# export UPDATE_MASTER=true
# export UPDATE_FUEL_MIRROR='http://mirror.fuel-infra.org/mos-repos/centos/mos7.0-centos6-fuel/proposed/x86_64/ http://mirror.fuel-infra.org/mos-repos/centos/mos7.0-centos6-fuel/security/x86_64/ http://mirror.fuel-infra.org/mos-repos/centos/mos7.0-centos6-fuel/updates/x86_64/'
# export EXTRA_DEB_REPOS='mos-updates-2,deb http://mirror.fuel-infra.org/mos-repos/ubuntu/7.0/ mos7.0-proposed main restricted'
# export EXTRA_DEB_REPOS_PRIORITY=1200


>$LOG
exec >  >(tee -a $LOG)
exec 2> >(tee -a $LOG >&2)

shopt -s nocasematch

usage() {
  progname=$(basename $0)
  echo -e "usage: $progname [ -i iso_path | -r release]  [ -d distro ] [ -t testgroup ] [ -n number ] [ -p path ] [--existing ] [ --destroy ] [--erase ] [ --fixnet ENV ] [ --revert-after ] [ --revert-vmw ]"
  echo -e "\t-i iso_path\tpath to MOS ISO, e.g: ~/Downloads/fuel-6.0-129-2014-11-22_22-01-00.iso"
  echo -e "\t-r release\tfuel release version, torrent client will be used to download last ISO for this release"
  echo -e "\t-d distro\tdistribution to install possible values: centos, ubuntu"
  echo -e "\t-t testgroup,\te.g: vcenter_one_node_simple, deploy_simple_nsx_stt, vcenter_empty, nsx_empty"
  echo -e "\t-n number\tnumber of nodes that libvirt will provision (2-22)"
  echo -e "\t-p path to the plugin rpm"
  echo -e "\t--existing\ttry to use existing env, else existing env with same name will be deleted before running"
  echo -e "\t--destroy\tshutoff libvirt nodes after completion"
  echo -e "\t--erase\t\tcompletely erase env if system test is successful"
  echo -e "\t--revert-after\trevert VMware Workstation VMs to clean state if system test is successful"
  echo -e "\t--revert-vmw\tjust revert VMware Workstation VMs"
  echo -e "\t--fixnet ENV\tfix network configuration of existing environment ENV"
  exit 255
}

args=$(getopt -o d:t:i:r:n:p: -l existing,erase,destroy,revert-after,fixnet,revert-vmw: -- "$@")

if [ $? -ne 0 -o $# -lt 1 ]; then
  usage
fi


eval set -- $args

check_arg() {
  opt=$1
  value=$2
  if [ "${value:0:1}" == "-" ]; then
    echo "option requires an argument -- '${opt:1:2}'"
    usage
    exit 1
  fi
}

WSLOGIN='vmware'
WSPASS='VMware01'

export EXT_NODES="esxi1 esxi2 esxi3 vcenter trusty"
[ -z $EXT_SNAPSHOT ] && export EXT_SNAPSHOT="nsxv"

while true; do
  case "$1" in
    -d)
      check_arg $1 $2
      shift
      distro=$1
      case "$distro" in
        "centos" ) export OPENSTACK_RELEASE="CentOS";;
        "ubuntu" ) export OPENSTACK_RELEASE="Ubuntu";;
        *) echo "Unknown distro: $distro"; exit 1;;
      esac
      ;;
    -t)
      check_arg $1 $2
      shift
      export TEST_GROUP="$1"
      ;;
    -i)
      check_arg $1 $2
      shift
      export ISO_PATH="$1"
      ;;
    -r)
      check_arg $1 $2
      shift
      GET_ISO="$1"
      case "$GET_ISO" in
        "5" ) GET_ISO="5.1.2";;
        "5.1" ) GET_ISO="5.1.2";;
        "6" ) GET_ISO="6.0.1";;
        "master" ) GET_ISO="6.1";;
      esac
      ;;
    -p)
      check_arg $1 $2
      shift
      export NSXV_PLUGIN_PATH="$1"
      ;;
    -n)
      check_arg $1 $2
      shift
      export NODES_COUNT="$1"
      if [ $NODES_COUNT -lt 2 -o $NODES_COUNT -gt 22 ]; then
        echo "Specified number of nodes is out of range 2-22"
        exit 1
      fi
      ;;
    --existing)
      USE_EXISTING=1
      ;;
    --erase)
      ERASE_ENV_AFTER=1
      ;;
    --destroy)
      DESTROY_ENV_AFTER=1
      ;;
    --revert-after)
      REVERT_AFTER=1
      ;;
    --revert-vmw)
      shift
      REVERT_WS=1
      ;;
    --fixnet)
      if [ $# -gt 3 ]; then echo "--fixnet should be used only with ENV name"; exit 1; fi
      shift
      FIXNET=$1
      ;;
    --)
      shift
      break
      ;;
  esac
  shift
done

if [ ! -f plugin_test/utils/jenkins/system_tests.sh -a -z "$FIXNET" ];
then
  echo "Please start this script inside fuel-qa or fuel-main directory"
  exit 1
fi

main() {
  if [ -n "$ISO_PATH" -a -n "$GET_ISO" ]; then echo "Path to ISO and release version to download both specified, please choose only one"; exit 1; fi

  if [ -z $TEST_GROUP ]; then 
    export TEST_GROUP="nsxv_smoke";
    echo "Choosing nsxv_smoke test group by default."
  fi

  if [ -n "$GET_ISO" -a -z "$MAGNET_LINK" ]; then
    echo "Getting latest ISO for Fuel release $GET_ISO"
    magneturl="$JENKINS_URL/job/${GET_ISO}.all/lastSuccessfulBuild/artifact/magnet_link.txt"
    res=$(curl -sf $magneturl) || { echo "Cannot download release ISO"; exit 1; }
    export $res
  fi

  if [ -z $WORKSPACE ]; then export WORKSPACE=$(pwd); fi
  if [ -n "$MAGNET_LINK" ]
  then
    export ISO_PATH=`seedclient-wrapper -d -m "${MAGNET_LINK}" -v --force-set-symlink -o "${WORKSPACE}"`
  fi

  #if [ -z $ISO_PATH ]; then echo "Please provide path to ISO with -i key"; exit 1; fi
  if [ ! -f "$ISO_PATH" -a -z "$USE_EXISTING" ]; then echo "Can't find ISO $ISO_PATH"; exit 1; fi

  export VERSION_STRING=`basename $ISO_PATH | cut -d '-' -f 2-3`
  
  #leave some artifacts
  echo $VERSION_STRING > iso_version.txt
  echo $MAGNET_LINK > magnet_link.txt
  
  echo "Description string: $VERSION_STRING $OPENSTACK_RELEASE $TEST_GROUP"

  # Export settings
  # this is must for granular deploy
  export SYNC_DEPL_TASKS=true
  if [ -z $ADMIN_NODE_MEMORY ]; then export ADMIN_NODE_MEMORY=4096; fi
  if [ -z $ADMIN_NODE_CPU ]; then export ADMIN_NODE_CPU=4; fi
  if [ -z $SLAVE_NODE_MEMORY ]; then export SLAVE_NODE_MEMORY=4096; fi
  if [ -z $SLAVE_NODE_CPU ]; then export SLAVE_NODE_CPU=4; fi

  #if [ -z $VENV_PATH ]; then export VENV_PATH=~jenkins/venv-nailgun-tests; fi
  [ -z $VIRTUAL_ENV ] && { echo "Please activate python venv before running this script(e.g. with 'source /home/jenkins/venv-nailgun-tests/bin/activate')"; exit 1; }
  if [ -z $OPENSTACK_RELEASE ]; then export OPENSTACK_RELEASE='CentOS'; fi
  if [ -z $NODES_COUNT ]; then export NODES_COUNT=10; fi
  if [ -z $JOB_NAME ]; then export JOB_NAME='manual_systest'; fi
  if [ -z $ENV_NAME ]; then export ENV_NAME=${ENV_PREFIX}${VERSION_STRING}_${OPENSTACK_RELEASE}_${TEST_GROUP}; fi

  # see https://bugs.launchpad.net/fuel/+bug/1418432
  ENV_NAME=${ENV_NAME:0:68}

  set_vcenter

  if [[ $TEST_GROUP == nsx_empty  || $TEST_GROUP == vcenter_empty ]]
  then
    case $NODES_COUNT in 
      [2-3]) TEST_GROUP="prepare_slaves_1" ;;
      [4-5]) TEST_GROUP="prepare_slaves_3" ;;
      [6-7]) TEST_GROUP="prepare_slaves_5" ;;
      [8-9]) TEST_GROUP="prepare_slaves_5" ;;
      [1-9][0-9]) TEST_GROUP="prepare_slaves_5" ;;
    esac
  fi

  if [ -n  "$USE_EXISTING" ]; then
    KEEPENV_BEFORE_OPT="-k";
  else
    dos.py list | grep -q $ENV_NAME && { echo erasing old $ENV_NAME; dos.py erase $ENV_NAME ; }
  fi
  if [ -z  "$DESTROY_ENV_AFTER" ]; then KEEPENV_AFTER_OPT="-K"; fi

  clean_old_bridges

  rm -rf logs/*

  #Run test in background and wait before environment is created
  echo sh -x "plugin_test/utils/jenkins/system_tests.sh" -t test $KEEPENV_BEFORE_OPT $KEEPENV_AFTER_OPT -e $ENV_NAME -w $WORKSPACE  -V $VIRTUAL_ENV -j $JOB_NAME -i "${ISO_PATH}" -o --group=$TEST_GROUP

  sh -x "plugin_test/utils/jenkins/system_tests.sh"  -t test $KEEPENV_BEFORE_OPT $KEEPENV_AFTER_OPT -e $ENV_NAME -w $WORKSPACE  -V $VIRTUAL_ENV -j $JOB_NAME -i "${ISO_PATH}" -o --group=$TEST_GROUP &

  SYSTEST_PID=$!

  if ! ps -p $SYSTEST_PID > /dev/null
  then
    echo System tests exited prematurely, aborting
    exit 1
  fi

  #Wait before environment is created
  while [ $(virsh net-list | grep $ENV_NAME | wc -l) -ne 5 ];do sleep 10
    if ! ps -p $SYSTEST_PID > /dev/null
    then
      echo System tests exited prematurely, aborting
      exit 1
    fi
  done
  sleep 10

  setup_net $ENV_NAME

  clean_iptables

  revert_ws "$EXT_NODES" || { echo "killing $SYSTEST_PID and its childs" && pkill --parent $SYSTEST_PID && kill $SYSTEST_PID && exit 1; }

  #fixme should use only one clean_iptables call
  clean_iptables

  echo waiting for system tests to finish
  wait $SYSTEST_PID

  export RES=$?
  echo ENVIRONMENT NAME is $ENV_NAME
  virsh net-dumpxml ${ENV_NAME}_admin | grep -P "(\d+\.){3}" -o | awk '{print "Fuel master node IP: "$0"2"}'

  echo Result is $RES

  #workaround for jenkins marking tests as failed on segfaults
  if [ $RES -eq 139 ]
  then
    grep 'errors="0"' nosetests.xml | grep -q 'failures="0"' && echo SEGFAULT workaround && RES=0
  fi 

  if [ $RES -eq 0 ]
  then
    echo Tests succeeded
    if [ -n  "$ERASE_ENV_AFTER" ]
    then
      echo Erasing $ENV_NAME
      dos.py erase $ENV_NAME
    #else
    #  snapname=success-$TESTGROUP-`date +%F-%R`
    #  echo Leaving $ENV_NAME with snapshot \'$snapname\'
    #  dos.py snapshot --snapshot-name $snapname $ENV_NAME
    fi
    if [ -n "$REVERT_AFTER" ]
    then
      revert_ws "$EXT_NODES"
    fi
  else
    echo  "$DESTROY_ENV_AFTER"
    [ -n "$DESTROY_ENV_AFTER" ] && dos.py destroy $ENV_NAME
    echo Tests failed
  fi

}


add_interface_to_bridge() {
  env=$1
  net_name=$2
  nic=$3  
  ip=$4

  for net in $(virsh net-list |grep ${env}_${net_name} |awk '{print $1}');do
    bridge=`virsh net-info $net |grep -i bridge |awk '{print $2}'`
    setup_bridge $bridge $nic $ip && echo $net_name bridge $bridge ready
  done
}

setup_bridge() {
  bridge=$1
  nic=$2
  ip=$3

  sudo /sbin/brctl stp $bridge off
  sudo /sbin/brctl addif $bridge $nic
  #set if with existing ip down
  for itf in `sudo ip -o addr show to $ip |cut -d' ' -f2`; do
      echo deleting $ip from $itf
      sudo ip addr del dev $itf $ip
  done
  echo adding $ip to $bridge
  sudo /sbin/ip addr add $ip dev $bridge
  echo $nic added to $bridge
  sudo /sbin/ip link set dev $bridge up
  if sudo /sbin/iptables-save |grep $bridge | grep -i reject| grep -q FORWARD;then
    sudo /sbin/iptables -D FORWARD -o $bridge -j REJECT --reject-with icmp-port-unreachable
    sudo /sbin/iptables -D FORWARD -i $bridge -j REJECT --reject-with icmp-port-unreachable
  fi
}

set_vcenter() {
  # If param is bool, use 'true' or 'false'.
  export DISABLE_SSL="true"
  export NEUTRON_SEGMENT_TYPE='tun'
  export VCENTER_USE="true"
  export VCENTER_IP="172.16.0.254"
  export VCENTER_USERNAME="administrator@vsphere.local"
  export VCENTER_PASSWORD="Qwer!1234"
  export VC_DATACENTER="Datacenter"
  export VC_DATASTORE="nfs"
  export VCENTER_IMAGE_DIR="/openstack_glance"

  export NSXV_MANAGER_IP='172.16.0.249'
  export NSXV_USER='admin'
  export NSXV_PASSWORD='r00tme'
  export NSXV_DATACENTER_MOID='datacenter-126'
  export NSXV_CLUSTER_MOID='domain-c131,domain-c133'
  export NSXV_RESOURCE_POOL_ID='resgroup-134'
  export NSXV_DATASTORE_ID='datastore-138'
  export NSXV_EXTERNAL_NETWORK='network-222'
  export NSXV_VDN_SCOPE_ID='vdnscope-1'
  export NSXV_DVS_ID='dvs-141'
  export NSXV_BACKUP_EDGE_POOL='service:compact:1:2,vdr:compact:1:2'
  export NSXV_MGT_NET_MOID='network-222'
  export NSXV_MGT_NET_PROXY_IPS='172.16.0.29'
  export NSXV_MGT_NET_PROXY_NETMASK='255.255.255.0'
  export NSXV_MGT_NET_DEFAULT_GW='172.16.0.1'
  export NSXV_EDGE_HA='true'
  export NSXV_INSECURE='true'

  export JOB_NAME="vcenter_system_test"
  export ENV_TYPE="vcenter"
  export EXT_IFS="vmnet1 vmnet2"

  export VCENTER_CLUSTERS="Cluster1"
}

clean_old_bridges() {
  for intf in $EXT_IFS; do
    for br in `/sbin/brctl show | grep -v "bridge name" | cut -f1 -d'	'`; do 
      /sbin/brctl show $br| grep -q $intf && sudo /sbin/brctl delif $br $intf \
        && sudo /sbin/ip link set dev $br down && echo $intf deleted from $br
    done
  done
}

clean_iptables() {
  sudo /sbin/iptables -F
  sudo /sbin/iptables -t nat -F
  sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

revert_ws() {
  SET_X=`case "$-" in *x*) echo "set -x" ;; esac`
  set +x

  for i in $1
  do
    vmrun -T ws-shared -h https://localhost:443/sdk -u $WSLOGIN -p $WSPASS listRegisteredVM | grep -q $i || { echo "VM $i does not exist"; continue; }
    echo vmrun: reverting $i to $EXT_SNAPSHOT 
    vmrun -T ws-shared -h https://localhost:443/sdk -u $WSLOGIN -p $WSPASS revertToSnapshot "[standard] $i/$i.vmx" $EXT_SNAPSHOT || { echo "Error: revert of $i failed";  return 1; }
    echo vmrun: starting $i
    vmrun -T ws-shared -h https://localhost:443/sdk -u $WSLOGIN -p $WSPASS start "[standard] $i/$i.vmx" || { echo "Error: $i failed to start";  return 1; }
  done
  $SET_X
}


setup_net() {
  env=$1
  add_interface_to_bridge $env private vmnet2 10.0.0.1/24
  add_interface_to_bridge $env public vmnet1 172.16.0.1/24
}


if [ -n "$REVERT_WS" ]; then
  revert_ws "$EXT_NODES"
  exit 1
fi

if [ -z $FIXNET ]; then
  main
else
  ENV=$FIXNET
  EXT_IFS="vmnet1 vmnet2"
  clean_old_bridges
  setup_net $ENV
fi

exit $RES
