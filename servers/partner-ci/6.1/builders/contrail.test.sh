#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

[ -z $CONTRAIL_VERSION ] && exit 1 || echo contrail version is $CONTRAIL_VERSION

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(cut -d'-' -f3-3 <<< $ISO_FILE) 
export FUEL_RELEASE=$(cut -d'-' -f2-2 <<< $ISO_FILE | tr -d '.') 

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

[[ -z ${CONTRAIL_PLUGIN_PATH} ]] && export CONTRAIL_PLUGIN_PATH=$(ls ${WORKSPACE}/contrail*.rpm) \
                                 || echo CONTRAIL_PLUGIN_PATH=$CONTRAIL_PLUGIN_PATH


#export JUNIPER_PKG_PATH="/storage/contrail/2.20/"
export JUNIPER_PKG_PATH="/storage/contrail/${CONTRAIL_VERSION}/"
#export CONTRAIL_PLUGIN_PACK_CEN_PATH=$(find ${JUNIPER_PKG_PATH} -type f -name '*rpm' )
#export CONTRAIL_PLUGIN_PACK_UB_PATH=$(find ${JUNIPER_PKG_PATH} -type f -name '*deb' )
export CONTRAIL_PLUGIN_PACK_UB_PATH=$(find $JUNIPER_PKG_PATH -maxdepth 1 -name 'contrail-install-packages*.deb' -exec stat -c "%y %n" {} + | sort -r | head -n 1 | cut -d' ' -f 4)
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
echo plugin-checksum: $(md5sum -b $DVS_PLUGIN_PATH)

./plugin_test/utils/jenkins/system_tests.sh -t test ${systest_parameters} -i ${ISO_PATH} -j ${JOB_NAME} -o --group=${TEST_GROUP}
