#!/bin/bash -e 

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(cut -d'-' -f3-3 <<< $ISO_FILE) 
export FUEL_RELEASE=$(cut -d'-' -f2-2 <<< $ISO_FILE | tr -d '.') 
export DVS_PLUGIN_PATH=$(ls ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm)

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"


echo "Description string: ${TEST_GROUP} on ${NODE_NAME}: ${ENV_NAME}"

source $VENV_PATH/bin/activate

systest_parameters=''
[[ $USE_SNAPSHOTS == "true"  ]] && systest_parameters+=' --existing' || echo new env will not be created
[[ $SHUTDOWN_AFTER == "true" ]] && systest_parameters+=' --destroy' || echo  the env will not be powered off after test
[[ $ERASE_AFTER  == "true"  ]] && systest_parameters+=' --erase' || echo the env will not be erased after test 

echo use-snapshots: $USE_SNAPSHOTS

echo venv-path: $VENV_PATH
echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH   
echo plugin-path: $DVS_PLUGIN_PATH
echo plugin path: $DVS_PLUGIN_PATH plugin checksum: $(md5sum -b $DVS_PLUGIN_PATH) 

cd plugin_test/
/btsync/tpi_systest.sh -i $ISO_PATH -d $OPENSTACK_RELEASE -t $TEST_GROUP -n $NODES_COUNT $systest_parameters
