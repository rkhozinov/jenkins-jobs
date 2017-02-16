#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x



[ -z ${MISTRAL_PLUGIN_PATH} ] && export MISTRAL_PLUGIN_PATH=$(ls -t ${WORKSPACE}/fuel-plugin-mistral*.rpm | head -n 1) \
                                 || echo MISTRAL_PLUGIN_PATH=$MISTRAL_PLUGIN_PATH


systest_parameters=''
[[ $USE_SNAPSHOTS == "true"  ]] && systest_parameters+=' -k' || echo new env will be created
[[ $ERASE_AFTER == "true"  ]] && echo "the env will be erased after test" || systest_parameters+=' -K'

echo -e "test-group: ${TEST_GROUP}\n \
env-name: ${ENV_NAME}\n \
use-snapshots: ${USE_SNAPSHOTS}\n \
fuel-release: ${FUEL_RELEASE}\n \
venv-path: ${VENV_PATH}\n \
env-name: ${ENV_NAME}\n \
iso-path: ${ISO_PATH}\n \
plugin-path: ${MISTRAL_PLUGIN_PATH}\n \
plugin-checksum: $(md5sum -b ${MISTRAL_PLUGIN_PATH})"

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

. "${VENV_PATH}/bin/activate"

sh -x "plugin_test/utils/jenkins/system_tests.sh" \
  -t test ${systest_parameters} \
  -i ${ISO_PATH} -j ${JOB_NAME} \
  -o --group=${TEST_GROUP}
