#!/bin/bash -ex 

export ISO_PATH="$ISO_STORAGE/$ISO_FILE"
export ISO_VERSION=`cut -d'-' -f4-4 <<< $ISO_FILE` 
export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export DVS_PLUGIN_PATH=$(ls ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm)

source $VENV_PATH/bin/activate

systest_parameters=''
[ $USE_SNAPSHOTS  ] && systest_parameters+=' --existing'
[ $SHUTDOWN_AFTER ] && systest_parameters+=' --destroy'
[ $ERASE_AFTER    ] && systest_parameters+=' --erase'

echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH   
echo plugin-path: $DVS_PLUGIN_PATH

/btsync/tpi_systest.sh -i $ISO_PATH -d $OPENSTACK_RELEASE -t $TEST_GROUP -n $NODES_COUNT $systest_parameters
