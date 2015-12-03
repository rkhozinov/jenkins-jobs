#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(cut -d'-' -f3-3 <<< $ISO_FILE) 
export FUEL_RELEASE=$(cut -d'-' -f2-2 <<< $ISO_FILE | tr -d '.') 

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"


source $VENV_PATH/bin/activate

systest_parameters=''
[[ $USE_SNAPSHOTS  == 'true' ]] && systest_parameters+=' --existing' || echo snapshots for env is not be used
[[ $SHUTDOWN_AFTER == 'true' ]] && systest_parameters+=' --destroy' || echo the env will not be removed after test
[[ $ERASE_AFTER    == 'true' ]] && systest_parameters+=' --erase' || echo the env will not be erased after test

echo test-group: $TEST_GROUP
echo env-name: $ENV_NAME
echo use-snapshots: $USE_SNAPSHOTS
echo fuel-release: $FUEL_RELEASE
echo venv-path: $VENV_PATH
echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH

/btsync/tpi_systest.sh -i $ISO_PATH -d $OPENSTACK_RELEASE -t $TEST_GROUP -n $NODES_COUNT $systest_parameters

