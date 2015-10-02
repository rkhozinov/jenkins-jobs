#!/bin/bash -ex 

export ISO_PATH="$ISO_STORAGE/$ISO_FILE"
source $VENV_PATH/bin/activate

systest_parameters=''
[ $USE_SNAPSHOTS  ] && systest_parameters+=' --existing'
[ $SHUTDOWN_AFTER ] && systest_parameters+=' --destroy'
[ $ERASE_AFTER    ] && systest_parameters+=' --erase'

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
echo env-name: $ENV_NAME
/btsync/tpi_systest.sh -i $ISO_PATH -d $OPENSTACK_RELEASE -t $TEST_GROUP -n $NODES_COUNT $systest_parameters
