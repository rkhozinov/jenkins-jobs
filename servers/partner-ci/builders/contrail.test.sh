#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

[ -z $CONTRAIL_VERSION ] && exit 1 || echo contrail version is $CONTRAIL_VERSION

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(cut -d- -f3-3 <<< $ISO_FILE) 
export FUEL_RELEASE=$(cut -d- -f2-2 <<< $ISO_FILE | tr -d '.') 

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[[ -z ${CONTRAIL_PLUGIN_PATH} ]] && export CONTRAIL_PLUGIN_PATH=$(ls -t ${WORKSPACE}/contrail*.rpm | head -n 1) \
                                 || echo CONTRAIL_PLUGIN_PATH=$CONTRAIL_PLUGIN_PATH


export JUNIPER_PKG_PATH="/storage/contrail/${CONTRAIL_VERSION}/"
export CONTRAIL_PLUGIN_PACK_UB_PATH=$(find $JUNIPER_PKG_PATH -maxdepth 1 -name 'contrail-install-packages*.deb' -exec stat -c "%y %n" {} + | sort -r | head -n 1 | cut -d' ' -f 4)
export JUNIPER_PKG_VERSION=$(sed 's/[-_~]/-/g' <<< ${CONTRAIL_PLUGIN_PACK_UB_PATH} | cut -d- -f4-5)
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
TEST_JOB_NAME=$JOB_NAME
TEST_JOB_BUILD_NUMBER=$BUILD_NUMBER
PKG_JOB_BUILD_NUMBER=$PKG_JOB_BUILD_NUMBER
PLUGIN_VERSION=$PLUGIN_VERSION
JUNIPER_PKG_VERSION=$JUNIPER_PKG_VERSION
REPORTER_PROPERTIES

./plugin_test/utils/jenkins/system_tests.sh -t test ${systest_parameters} -i ${ISO_PATH} -j ${JOB_NAME} -o --group=${TEST_GROUP}
