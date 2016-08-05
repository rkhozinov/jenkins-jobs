#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x
[ -z $ISO_FILE  ] && (echo "ISO_FILE variable is empty"; exit 1)

[ ${SNAPSHOTS_ID} ] && export SNAPSHOTS_ID=${SNAPSHOTS_ID} || export SNAPSHOTS_ID=${CUSTOM_VERSION:10}
[ -z "${SNAPSHOTS_ID}" ] && { echo SNAPSHOTS_ID is empty; exit 1; }


if [ -z $PLUGIN_VERSION  ]; then
  if [ -f build.plugin_version ]; then
    export PLUGIN_VERSION=$(grep "PLUGIN_VERSIONR" < build.plugin_version | cut -d= -f2 )
    export DVS_PLUGIN_VERSION=$PLUGIN_VERSION
  fi
fi

if [ -z "${PKG_JOB_BUILD_NUMBER}" ]; then
    if [ -f build.properties ]; then
        export PKG_JOB_BUILD_NUMBER=$(grep "BUILD_NUMBER" < build.properties | cut -d= -f2 )
    else
        echo "build.properties file is not available so the results couldn't be publihsed"
        echo "$PKG_JOB_BUILD_NUMBER is empty, but it's needed for reporter. Exit."
        exit 1
    fi
fi

#remove old logs and test data
[ -f nosetest.xml ] && sudo rm -f nosetests.xml
sudo rm -rf logs/*

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
fi

export ENV_NAME="${ENV_PREFIX}.${SNAPSHOTS_ID}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[ -z "${DVS_PLUGIN_PATH}" ] && export DVS_PLUGIN_PATH=$(ls -t ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm | head -n 1)
[ -z "${DVS_PLUGIN_PATH}" ] && { echo "DVS_PLUGIN_PATH is empty"; exit 1; }
[ -z "${PLUGIN_PATH}"     ] && export PLUGIN_PATH=$DVS_PLUGIN_PATH

systest_parameters=''
[[ $USE_SNAPSHOTS  == 'true' ]] && systest_parameters+=' -K -k' || echo snapshots for env is not be used
#[[ $SHUTDOWN_AFTER == 'true' ]] && systest_parameters+=' --destroy' || echo the env will not be removed after test
#[[ $ERASE_AFTER    == 'true' ]] && systest_parameters+=' --erase' || echo the env will not be erased after test

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

clean_iptables() {
  sudo /sbin/iptables -F
  sudo /sbin/iptables -t nat -F
  sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

sh -x "utils/jenkins/system_tests.sh" \
    -t test $systest_parameters \
    -i "${ISO_PATH}" \
    -o --group="${TEST_GROUP_PREFIX}(${TEST_GROUP_CONFIG})" &

export SYSTEST_PID=$!

#Wait before environment is created
while [ true ]; do 
  [ $(virsh net-list | grep $ENV_NAME | wc -l) -eq 5 ] && break || sleep 10
  [ -e /proc/$SYSTEST_PID ] && continue || \
    { echo System tests exited prematurely, aborting; exit 1; }
done

clean_iptables
add_interface_to_bridge $ENV_NAME private vmnet2

echo "Waiting for system tests to finish"
wait $SYSTEST_PID
export RESULT=$?

echo "ENVIRONMENT NAME is $ENV_NAME"
virsh net-dumpxml "${ENV_NAME}_admin" | grep -P "(\d+\.){3}" -o | awk '{print "Fuel master node IP: "$0"2"}'

[ $RESULT -eq 0 ] && { echo "Tests succeeded"; exit $RESULT; }
