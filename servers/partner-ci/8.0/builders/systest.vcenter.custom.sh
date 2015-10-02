#!/bin/bash -ex 

export ISO_PATH="$ISO_STORAGE/$ISO_FILE"
source $VENV_PATH/bin/activate

systest_parameters=''
[ $USE_SNAPSHOTS  ] && systest_parameters+=' --existing'
[ $SHUTDOWN_AFTER ] && systest_parameters+=' --destroy'
[ $ERASE_AFTER    ] && systest_parameters+=' --erase'

if [ -z $FUEL_QA_GERRIT_COMMIT ] ; then
    for commit in $FUEL_QA_GERRIT_COMMIT; do
        git fetch $GIT_URL "${commit}" && git cherry-pick FETCH_HEAD
    done
fi
export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
/btsync/tpi_systest.sh -i $ISO_PATH -d $OPENSTACK_RELEASE -t $TEST_GROUP -n $NODES_COUNT $systest_parameters
