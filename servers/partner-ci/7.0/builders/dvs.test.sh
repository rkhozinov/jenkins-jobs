#!/bin/bash -e 

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(cut -d'-' -f3-3 <<< $ISO_FILE) 
export FUEL_RELEASE=$(cut -d'-' -f2-2 <<< $ISO_FILE | tr -d '.') 

[[ -z "${DVS_PLUGIN_PATH}" ]] && export DVS_PLUGIN_PATH=$(ls ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm) || true

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

echo "Description string: ${TEST_GROUP} on ${NODE_NAME}: ${ENV_NAME}"

source $VENV_PATH/bin/activate

systest_parameters=''
[[ $USE_SNAPSHOTS == "true"  ]] && systest_parameters+=' -k' || echo new env will be created
[[ $ERASE_AFTER  == "true"  ]] && echo the env will be erased after test || systest_parameters+=' -K' 

echo use-snapshots: $USE_SNAPSHOTS
echo venv-path: $VENV_PATH
echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH   
echo plugin-path: $DVS_PLUGIN_PATH
echo plugin path: $DVS_PLUGIN_PATH 
echo plugin checksum: $(md5sum -b $DVS_PLUGIN_PATH) 

./plugin_test/utils/jenkins/system_tests.sh -t test ${systest_parameters} -i ${ISO_PATH} -j ${JOB_NAME} -o --group=${TEST_GROUP}
