#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

export ISO_PATH=${ISO_PATH:-${ISO_STORAGE}/${ISO_FILE}}

if [[ $ISO_FILE == *"custom"* ]]; then
  export FUEL_RELEASE=90
else
  export FUEL_RELEASE=$(echo "${ISO_FILE}" | cut -d- -f2 | tr -d '.iso')
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
  export SNAPSHOTS_ID=$(grep -Po '#\K[^ ]+' < snapshots.params )

[ -f build.plugin_version ] && \
  export PLUGIN_VERSION=$(grep "PLUGIN_VERSION" < build.plugin_version | cut -d= -f2 )

[ -z $NSXV_PLUGIN_VERSION  ] && \
    export NSXV_PLUGIN_VERSION=${PLUGIN_VERSION:?}

if [ -z "${PKG_JOB_BUILD_NUMBER}" ]; then
    if [ -f build.properties ]; then
        export PKG_JOB_BUILD_NUMBER=$(grep "^BUILD_NUMBER" < build.properties | cut -d= -f2 )
    else
        : ${PKG_JOB_BUILD_NUMBER?}
        echo -e "build.properties file is not available so \
                 the results couldn't be publihsed\n \
                 PKG_JOB_BUILD_NUMBER is empty, but it's needed for reporter."
    fi
fi

#remove old logs and test data
[ -f nosetest.xml ] && rm -f nosetests.xml
rm -rf logs/*

export ENV_NAME="${ENV_PREFIX}.${SNAPSHOTS_ID}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

export NSXV_PLUGIN_PATH="${NSXV_PLUGIN_PATH:-$(ls -t ${WORKSPACE}/nsxv*.rpm | head -n 1)}"
export PLUGIN_PATH="${PLUGIN_PATH:-$NSXV_PLUGIN_PATH}"

systest_parameters=''
[[ $FORCE_REUSE == "true"  ]] && systest_parameters+=' -k' || echo "new env will be created"
[[ $ERASE_AFTER   == "true"  ]] && echo "the env will be erased after test" || systest_parameters+=' -K'

echo -e "test-group: ${TEST_GROUP}\n \
env-name: ${ENV_NAME}\n \
use-snapshots: ${USE_SNAPSHOTS}\n \
fuel-release: ${FUEL_RELEASE}\n \
venv-path: ${VENV_PATH}\n \
env-name: ${ENV_NAME}\n \
iso-path: ${ISO_PATH}\n \
plugin-path: ${NSXV_PLUGIN_PATH}\n \
plugin-checksum: $(md5sum -b ${NSXV_PLUGIN_PATH})\n"

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

bash plugin_test/utils/jenkins/system_tests.sh \
  -t test ${systest_parameters} \
  -i ${ISO_PATH} -j ${JOB_NAME} \
  -o --group=${TEST_GROUP} 2>&1

dos.py list --ips | grep ${ENV_NAME}
