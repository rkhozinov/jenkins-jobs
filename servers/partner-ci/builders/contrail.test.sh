#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

[[ "${FORCE_VSRX_COPY}" == "true" ]] && sudo rm -rf $VSRX_TARGET_IMAGE_PATH 
[ ! -f $VSRX_TARGET_PATH ] && sudo cp $VSRX_ORGINAL_IMAGE_PATH $VSRX_TARGET_PATH
[ ! -f $VSRX_TARGET_PATH ] && { echo "ERROR: $VSRX_TARGET_PATH is not found"; exit 1; }

[ $CONTRAIL_VERSION ] && echo "contrail version is $CONTRAIL_VERSION" \
                      || { echo "CONTRAIL_VERSION is not defined";  exit 1; }

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
  [[ "${UPDATE_MASTER}" -eq "true" ]] && export ISO_VERSION='mos-mu' || export ISO_VERSION='mos'
fi

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[[ -z ${CONTRAIL_PLUGIN_PATH} ]] && export CONTRAIL_PLUGIN_PATH=$(ls -t ${WORKSPACE}/contrail*.rpm | head -n 1) \
                                 || echo "CONTRAIL_PLUGIN_PATH=$CONTRAIL_PLUGIN_PATH"


export JUNIPER_PKG_PATH="/storage/contrail/${CONTRAIL_VERSION}/"
[ -d $JUNIPER_PKG_PATH ] && echo "JUNIPER_PKG_PATH is $JUNIPER_PKG_PATH" \
                         || { echo "$JUNIPER_PKG_PATH is not found";  exit 1; }

[ -z $CONTRAIL_PLUGIN_PACK_UB_PATH ] && \
  export CONTRAIL_PLUGIN_PACK_UB_PATH=$(find $JUNIPER_PKG_PATH -maxdepth 1 -name 'contrail-install-packages*.deb' -exec stat -c "%y %n" {} + | sort -r | head -n 1 | cut -d' ' -f 4)
[ -f $CONTRAIL_PLUGIN_PACK_UB_PATH ] && echo "CONTRAIL_PLUGIN_PACK_UB_PATH is $CONTRAIL_PLUGIN_PACK_UB_PATH" \
                         || { echo "CONTRAIL_PLUGIN_PACK_UB_PATH is not found";  exit 1; }
export JUNIPER_PKG_VERSION=$(sed 's/[-_~]/-/g' <<< ${CONTRAIL_PLUGIN_PACK_UB_PATH} | cut -d- -f4-5)

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
JUNIPER_PKG_VERSION=$JUNIPER_PKG_VERSION
REPORTER_PROPERTIES

source $VENV_PATH/bin/activate
./plugin_test/utils/jenkins/system_tests.sh -t test ${systest_parameters} -i ${ISO_PATH} -j ${JOB_NAME} -o --group=${TEST_GROUP}
