#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

[ -z "$(ls -A ./plugin_test/fuel-qa)" ] && { echo "fuel-qa is not exists or empty"; exit 1; }


ISO_FILE_ARTIFACT='iso_file'
# if user entered custom iso we should use it
if [ -z $ISO_FILE  ]; then
   # but if use doesn't want custom iso, we should get iso from artifacts
   [ -f $ISO_FILE_ARTIFACT ] && source $ISO_FILE_ARTIFACT || (echo "There's not iso_file"; exit 1)
   # check variable again - it shouldn't be empty
   [ -z $ISO_FILE  ] && (echo "ISO_FILE variable is empty"; exit 1)
fi

PLUGIN_VERSION_ARTIFACT='build.plugin_version'
# if user entered custom iso we should use it

if [ -z $PLUGIN_VERSION  ]; then
   # but if use doesn't want custom iso, we should get iso from artifacts
   [ -f $PLUGIN_VERSION_ARTIFACT ] && source $PLUGIN_VERSION_ARTIFACT || (echo "The PLUGIN_VERSION is empty"; exit 1)
fi

[ -z $PLUGIN_VERSION  ] && (echo "PLUGIN_VERSION variable is empty"; exit 1) || export DVS_PLUGIN_VERSION=$PLUGIN_VERSION

if [ -z "${PKG_JOB_BUILD_NUMBER}" ]; then
    if [ -f build.properties ]; then
        export PKG_JOB_BUILD_NUMBER=$(grep "BUILD_NUMBER" < build.properties | cut -d= -f2 )
    else
        echo "build.properties file is not available so the results couldn't be publihsed"
        echo "$PKG_JOB_BUILD_NUMBER is empty, but it's needed for reporter. Exit."
        exit 1
    fi
fi

#remove old logs and test data
[ -f nosetest.xml ] && rm -f nosetests.xml
rm -rf logs/*

export FUEL_RELEASE=$(cut -d- -f2-2 <<< ${ISO_FILE} | tr -d '.')
export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(echo "${ISO_FILE}" | cut -d'-' -f3-3 | tr -d '.iso' )
export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[ -z "${DVS_PLUGIN_PATH}" ] && export DVS_PLUGIN_PATH=$(ls -t ${WORKSPACE}/fuel-plugin-vmware-dvs*.rpm | head -n 1)

[ -z "${DVS_PLUGIN_PATH}" ] && ( echo "DVS_PLUGIN_PATH is empty"; exit 1 ) 

[ -z "${PLUGIN_PATH}"     ] && export PLUGIN_PATH=$DVS_PLUGIN_PATH


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
echo "plugin-path: ${DVS_PLUGIN_PATH}"
echo "plugin-checksum: $(md5sum -b ${DVS_PLUGIN_PATH})"

cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=$ISO_VERSION
ISO_FILE=$ISO_FILE
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

