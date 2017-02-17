#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x


gcs_plugin_path=$(ls -t ${WORKSPACE}/fuel-plugin-cinder-gcs*.rpm | head -n 1)
export GCS_PLUGIN_PATH=${GCS_PLUGIN_PATH:-$gcs_plugin_path}
export PLUGIN_PATH=${PLUGIN_PATH:-$GCS_PLUGIN_PATH}


systest_parameters=''
[[ $USE_SNAPSHOTS == "true"  ]] && systest_parameters+=' -k' || echo new env will be created
[[ $ERASE_AFTER   == "true"  ]] && echo the env will be erased after test || systest_parameters+=' -K'

echo -e "test-group: ${TEST_GROUP}\n \
env-name: ${ENV_NAME}\n \
use-snapshots: ${USE_SNAPSHOTS}\n \
fuel-release: ${FUEL_RELEASE}\n \
venv-path: ${VENV_PATH}\n \
env-name: ${ENV_NAME}\n \
iso-path: ${ISO_PATH}\n \
plugin-path: ${GCS_PLUGIN_PATH}\n \
plugin-checksum: $(md5sum -b ${GCS_PLUGIN_PATH})\n"

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=${SNAPSHOTS_ID:?}
SNAPSHOTS_ID=${SNAPSHOTS_ID:?}
ISO_FILE=${ISO_FILE:?}
TEST_GROUP=${TEST_GROUP:?}
TEST_JOB_NAME=${JOB_NAME:?}
TEST_JOB_BUILD_NUMBER=${BUILD_NUMBER:?}
PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:?}
PLUGIN_VERSION=${PLUGIN_VERSION:?}
REPORTER_PROPERTIES

source $VENV_PATH/bin/activate

sh -x "plugin_test/utils/jenkins/system_tests.sh" \
  -t test ${systest_parameters} \
  -i ${ISO_PATH} -j ${JOB_NAME} \
  -o --group=${TEST_GROUP}
