#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

[[ -z "${ISO_FILE}" ]] && exit 1 || true

[[ -z "${PLUGIN_VERSION}" ]] && exit 1 || export DVS_PLUGIN_VERSION=${PLUGIN_VERSION}

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(cut -d'-' -f3-3 <<< $ISO_FILE) 
export FUEL_RELEASE=$(cut -d'-' -f2-2 <<< $ISO_FILE | tr -d '.')

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[[ -z "${DVS_PLUGIN_PATH}" ]] && export DVS_PLUGIN_PATH=$(ls -t ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm | head -n 1) || true

source $VENV_PATH/bin/activate

systest_parameters=''
[[ $USE_SNAPSHOTS  == 'true' ]] && systest_parameters+=' --existing' || echo snapshots for env is not be used
[[ $SHUTDOWN_AFTER == 'true' ]] && systest_parameters+=' --destroy' || echo the env will not be removed after test
#[[ $ERASE_AFTER    == 'true' ]] && systest_parameters+=' --erase' || echo the env will not be erased after test

[ -z $TEST_GROUP_PREFIX ] && exit 1 || echo test-group-prefix: $TEST_GROUP_PREFIX
echo test-group: $TEST_GROUP
echo env-name: $ENV_NAME
echo use-snapshots: $USE_SNAPSHOTS
echo fuel-release: $FUEL_RELEASE
echo venv-path: $VENV_PATH
echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH   
echo plugin-path: $DVS_PLUGIN_PATH
echo plugin-checksum: $(md5sum -b $DVS_PLUGIN_PATH)

#~/tpi_systest_mod.sh -i /storage/downloads/fuel-8.0-<build_number> -t system_test.vcenter.<test_name>.<yaml_file>

/btsync/tpi_systest_mod.sh -d ${OPENSTACK_RELEASE} \
                           -n ${NODES_COUNT} \
                           -i ${ISO_PATH} \
                           -t "${TEST_GROUP_PREFIX}(${TEST_GROUP})" \
                           $systest_parameters

#./plugin_test/utils/jenkins/system_tests.sh -t test ${systest_parameters} -i ${ISO_PATH} -j ${JOB_NAME} -o --group=${TEST_GROUP}

