#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x


export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
fi

export ENV_NAME="${ENV_PREFIX}.${SNAPSHOTS_ID}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

source $VENV_PATH/bin/activate

systest_parameters=''
[[ $USE_SNAPSHOTS == "true"  ]] && systest_parameters+=' -k' || echo new env will be created
[[ $ERASE_AFTER   == "true"  ]] && echo the env will be erased after test || systest_parameters+=' -K'

echo test-group: $TEST_GROUP
echo env-name: $ENV_NAME
echo use-snapshots: $USE_SNAPSHOTS
echo fuel-release: $FUEL_RELEASE
echo venv-path: $VENV_PATH
echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH   
echo plugin-path: $CONTRAIL_PLUGIN_PATH
echo ubuntu-plugin-path: $CONTRAIL_PLUGIN_PACK_UB_PATH
echo juniper-package-version: $JUNIPER_PKG_VERSION
echo plugin-checksum: $(md5sum -b $DVS_PLUGIN_PATH)

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=$ISO_VERSION
ISO_FILE=$ISO_FILE
TEST_GROUP=$TEST_GROUP
TEST_JOB_NAME=$JOB_NAME
TEST_JOB_BUILD_NUMBER=$BUILD_NUMBER
PKG_JOB_BUILD_NUMBER=$PKG_JOB_BUILD_NUMBER
PLUGIN_VERSION=$PLUGIN_VERSION
REPORTER_PROPERTIES

./plugin_test/utils/jenkins/system_tests.sh -t test ${systest_parameters} -i ${ISO_PATH} -j ${JOB_NAME} -o --group=${TEST_GROUP}
