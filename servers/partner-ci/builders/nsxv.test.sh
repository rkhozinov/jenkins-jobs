#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
[ -z $ISO_PATH  ] && { echo "ISO_PATH is empty or doesn't exist"; exit 1; }

if [[ $ISO_FILE == *"custom"* ]]; then
  export FUEL_RELEASE=90
else
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
fi

if [ "${SNAPSHOTS_ID}" != "released" ]; then
  if [[ "${UPDATE_MASTER}" == "true" ]] && [[ ${FUEL_RELEASE} != *"80"* ]]; then
    if [ -f $SNAPSHOT_OUTPUT_FILE ]; then
      . $SNAPSHOT_OUTPUT_FILE
      export EXTRA_RPM_REPOS
      export UPDATE_FUEL_MIRROR
      export EXTRA_DEB_REPOS
    else
      echo "SNAPSHOT_OUTPUT_FILE is empty or doesn't exist"; exit 1
    fi
  else
    export SNAPSHOTS_ID="released"
  fi
fi

[[ $SNAPSHOTS_ID == *"lastSuccessfulBuild"* ]] && \
  export SNAPSHOTS_ID=$(cat snapshots.params | grep -Po '#\K[^ ]+')

[ -z "${SNAPSHOTS_ID}" ] && { echo SNAPSHOTS_ID is empty; exit 1; }

if [ -f build.plugin_version ]; then
  export PLUGIN_VERSION=$(grep "PLUGIN_VERSION" < build.plugin_version | cut -d= -f2 )
else
  if [ -z $PLUGIN_VERSION ]; then
    echo "build.properties file is not available so a test couldn't be runned"
    exit 1
  fi
fi

[ -z $PLUGIN_VERSION  ] && { echo "PLUGIN_VERSION variable is empty"; exit 1; } || export NSXV_PLUGIN_VERSION=$PLUGIN_VERSION

if [ -z "${PKG_JOB_BUILD_NUMBER}" ]; then
    if [ -f build.properties ]; then
        export PKG_JOB_BUILD_NUMBER=$(grep "^BUILD_NUMBER" < build.properties | cut -d= -f2 )
    else
        echo "build.properties file is not available so the results couldn't be publihsed"
        echo "$PKG_JOB_BUILD_NUMBER is empty, but it's needed for reporter. Exit."
        exit 1
    fi
fi

#remove old logs and test data
[ -f nosetest.xml ] && rm -f nosetests.xml
rm -rf logs/*



export ENV_NAME="${ENV_PREFIX}.${SNAPSHOTS_ID}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[ -z "${NSXV_PLUGIN_PATH}"  ] && export NSXV_PLUGIN_PATH=$(ls -t ${WORKSPACE}/nsxv*.rpm | head -n 1)
[ -z "${NSXV_PLUGIN_PATH}"  ] && { echo "NSXV_PLUGIN_PATH is empty"; exit 1; }
[ -z "${PLUGIN_PATH}"       ] && export PLUGIN_PATH=$NSXV_PLUGIN_PATH

systest_parameters=''
[[ $USE_SNAPSHOTS == "true"  ]] && systest_parameters+=' -k' || echo "new env will be created"
[[ $ERASE_AFTER   == "true"  ]] && echo "the env will be erased after test" || systest_parameters+=' -K'

echo "test-group: ${TEST_GROUP}"
echo "env-name: ${ENV_NAME}"
echo "use-snapshots: ${USE_SNAPSHOTS}"
echo "fuel-release: ${FUEL_RELEASE}"
echo "venv-path: ${VENV_PATH}"
echo "env-name: ${ENV_NAME}"
echo "iso-path: ${ISO_PATH}"
echo "plugin-path: ${NSXV_PLUGIN_PATH}"
echo "plugin-checksum: $(md5sum -b ${NSXV_PLUGIN_PATH})"

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=$SNAPSHOTS_ID
SNAPSHOTS_ID=$SNAPSHOTS_ID
ISO_FILE=$ISO_FILE
TEST_GROUP=$TEST_GROUP
TEST_JOB_NAME=$JOB_NAME
TEST_JOB_BUILD_NUMBER=$BUILD_NUMBER
PKG_JOB_BUILD_NUMBER=$PKG_JOB_BUILD_NUMBER
PLUGIN_VERSION=$PLUGIN_VERSION
TREP_TESTRAIL_SUITE=${TREP_TESTRAIL_SUITE}
TREP_TESTRAIL_SUITE_DESCRIPTION=$TREP_TESTRAIL_SUITE_DESCRIPTION
TREP_TESTRAIL_PLAN=$TREP_TESTRAIL_PLAN
TREP_TESTRAIL_PLAN_DESCRIPTION=$TREP_TESTRAIL_PLAN_DESCRIPTION
DATE=$(date +'%B-%d')
REPORTER_PROPERTIES

source "${VENV_PATH}/bin/activate"

./plugin_test/utils/jenkins/system_tests.sh -t test ${systest_parameters} -i ${ISO_PATH} -j ${JOB_NAME} -o --group=${TEST_GROUP} 2>&1
sudo cp /var/log/libvirt/libvirtd.log ${WORKSPACE}/libvirtd_after_test.log
sudo chown jenkins:jenkins ${WORKSPACE}/libvirtd_after_test.log
