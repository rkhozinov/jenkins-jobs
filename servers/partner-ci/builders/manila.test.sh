#!/bin/bash -e
[[ "${DEBUG}" == "true" ]] && set -x || set +x

export ISO_PATH=${ISO_PATH:-"$ISO_STORAGE/$ISO_FILE"}

fuel_release=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
export FUEL_RELEASE=$fuel_release

if [ "${SNAPSHOTS_ID}" != "released" ]; then
  if [[ "${UPDATE_MASTER}" == "true" ]] && [[ ${FUEL_RELEASE} != *"80"* ]]; then
    if [ -f $SNAPSHOT_OUTPUT_FILE ]; then
      . $SNAPSHOT_OUTPUT_FILE
      export EXTRA_RPM_REPOS
      export UPDATE_FUEL_MIRROR
      export EXTRA_DEB_REPOS
    else
      echo "SNAPSHOT_OUTPUT_FILE is empty or doesn't exist"
      exit 1
    fi
  else
    export SNAPSHOTS_ID="released"
  fi
fi

[[ $SNAPSHOTS_ID == *"lastSuccessfulBuild"* ]] && \
  export SNAPSHOTS_ID=$(grep -Po '#\K[^ ]+' < snapshots.params)

if [ "${SNAPSHOTS_ID}" != "released" ]; then
  version=$(grep "PLUGIN_VERSION" < build.plugin_version | cut -d= -f2 )
  export PLUGIN_VERSION=${version:?}
fi

export MANILA_PLUGIN_VERSION=${PLUGIN_VERSION:?}

[ ! -f $MANILA_IMAGE_PATH ] && \
  { echo "MANILA_IMAGE_PATH is empty or doesn't exist"; exit 1; }

build_version=$(grep "BUILD_NUMBER" < build.properties | cut -d= -f2 )
export PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:-$build_version}


export ENV_NAME="${ENV_PREFIX:?}.${SNAPSHOTS_ID:?}"
export VENV_PATH="${HOME}/${FUEL_RELEASE:?}-venv"

manila_plugin_path=$(ls -t ${WORKSPACE}/fuel-plugin-manila*.rpm | head -n 1)
export MANILA_PLUGIN_PATH=${MANILA_PLUGIN_PATH:-$manila_plugin_path}
export PLUGIN_PATH=${PLUGIN_PATH:-$MANILA_PLUGIN_PATH}

echo -e "test-group: ${TEST_GROUP}\n \
env-name: ${ENV_NAME}\n \
use-snapshots: ${USE_SNAPSHOTS}\n \
fuel-release: ${FUEL_RELEASE}\n \
venv-path: ${VENV_PATH}\n \
env-name: ${ENV_NAME}\n \
iso-path: ${ISO_PATH}\n \
plugin-path: ${MANILA_PLUGIN_PATH}\n \
plugin-checksum: $(md5sum -b ${MANILA_PLUGIN_PATH})\n"

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=${SNAPSHOTS_ID:?}
SNAPSHOTS_ID=${SNAPSHOTS_ID:?}
ISO_FILE=${ISO_FILE:?}
TEST_GROUP=${TEST_GROUP:?}
TEST_JOB_NAME=${JOB_NAME:?}
TEST_JOB_BUILD_NUMBER=${BUILD_NUMBER:?}
PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:?}
PLUGIN_VERSION=${PLUGIN_VERSION:?}
MANILA_PLUGIN_VERSION=${MANILA_PLUGIN_VERSION:?}
DATE=$(date +'%B-%d')
REPORTER_PROPERTIES

. "${VENV_PATH}/bin/activate"

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
    sudo brctl show $bridge
    sudo ip address show $bridge
    sudo ip address show $nic
  fi
}

clean_iptables() {
  sudo /sbin/iptables -F
  sudo /sbin/iptables -t nat -F
  sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

# run python test set to create environments, deploy and test product
# WORKAROUND for https://bugs.launchpad.net/fuel/+bug/1642991
export WORKSPACE="${WORKSPACE}/plugin_test/fuel-qa"
export PLUGIN_WORKSPACE="${WORKSPACE/\/fuel-qa}"
export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}${WORKSPACE}:${PLUGIN_WORKSPACE}"
[[ "${DEBUG}" == "true" ]] && echo "PYTHONPATH:${PYTHONPATH} PATH:${PATH} WORKSPACE:${WORKSPACE}"
python $PLUGIN_WORKSPACE/run_tests.py -q --nologcapture --with-xunit --group=${TEST_GROUP} &
export SYSTEST_PID=$!

#Wait before environment is created
while true ; do
  [ $(virsh net-list | grep -c $ENV_NAME) -eq 5 ] && break || sleep 10
  [ -e /proc/$SYSTEST_PID ] && continue || \
    { echo System tests exited prematurely, aborting; exit 1; }
done

[[ "${CLEAN_IPTABLES}" == "true" ]] && clean_iptables

for iface_map in $(echo $WORKSTATION_IFS | tr ',' ' '); do
    iface=$(echo $iface_map | cut -d: -f1)
    network=$(echo $iface_map | cut -d: -f2)
    add_interface_to_bridge $ENV_NAME $network $iface
done

[[ "${DEBUG}" == "true" ]] && \
    sudo iptables -L -v -n;   \
    sudo iptables -t nat -L -v -n

echo "Waiting for system tests to finish"
wait $SYSTEST_PID
export RESULT=$?

echo "ENVIRONMENT NAME is $ENV_NAME"
dos.py list --ips | grep ${ENV_NAME}

[ $RESULT -eq 0 ] && { echo "Tests succeeded"; exit $RESULT; }
