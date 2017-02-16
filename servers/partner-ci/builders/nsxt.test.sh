#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x


if [ "${SNAPSHOTS_ID}" != "released" ]; then
  version=$(grep "PLUGIN_VERSION" < build.plugin_version | cut -d= -f2 )
  export PLUGIN_VERSION=${version:?}
fi
export NSXT_PLUGIN_VERSION=${PLUGIN_VERSION:?}

build_version=$(grep "BUILD_NUMBER" < build.properties | cut -d= -f2 )
export PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:-$build_version}



export NSXT_PLUGIN_PATH="${NSXT_PLUGIN_PATH:-$(ls -t ${WORKSPACE}/nsx-t*.rpm | head -n 1)}"
plugin_path="${PLUGIN_PATH:-$NSXT_PLUGIN_PATH}"
export PLUGIN_PATH=${plugin_path:?}

systest_parameters=''
[[ $FORCE_REUSE == "true"  ]] && systest_parameters+=' -k' || echo "new env will be created"
[[ $ERASE_AFTER == "true"  ]] && echo "the env will be erased after test" || systest_parameters+=' -K'

echo -e "test-group: ${TEST_GROUP}\n \
env-name: ${ENV_NAME}\n \
use-snapshots: ${USE_SNAPSHOTS}\n \
fuel-release: ${FUEL_RELEASE}\n \
venv-path: ${VENV_PATH}\n \
env-name: ${ENV_NAME}\n \
iso-path: ${ISO_PATH}\n \
plugin-path: ${NSXT_PLUGIN_PATH}\n \
plugin-checksum: $(md5sum -b ${NSXT_PLUGIN_PATH})"

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=${SNAPSHOTS_ID:?}
SNAPSHOTS_ID=${SNAPSHOTS_ID:?}
ISO_FILE=${ISO_FILE:?}
TEST_GROUP=${TEST_GROUP:?}
TEST_JOB_NAME=${JOB_NAME:?}
TEST_JOB_BUILD_NUMBER=${BUILD_NUMBER:?}
PKG_JOB_BUILD_NUMBER=${PKG_JOB_BUILD_NUMBER:?}
PLUGIN_VERSION=${PLUGIN_VERSION:?}
NSXT_PLUGIN_VERSION=${PLUGIN_VERSION:?}
DATE=$(date +'%B-%d')
REPORTER_PROPERTIES

. "${VENV_PATH}/bin/activate"

bash plugin_test/utils/jenkins/system_tests.sh \
  -t test ${systest_parameters} \
  -i ${ISO_PATH} -j ${JOB_NAME} \
  -o --group=${TEST_GROUP} 2>&1

if [[ "${DEBUG}" == "true" ]]; then
  sudo cp /var/log/libvirt/libvirtd.log ${WORKSPACE}/libvirtd_after_test.log
  sudo chown jenkins:jenkins ${WORKSPACE}/libvirtd_after_test.log
fi
