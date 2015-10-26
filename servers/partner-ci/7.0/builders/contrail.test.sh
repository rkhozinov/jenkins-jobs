#!/bin/bash -e 

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export ISO_VERSION=$(cut -d'-' -f3-3 <<< $ISO_FILE) 
export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"

export CONTRAIL_PLUGIN_PATH=$(ls ${WORKSPACE}/fuel-plugin-contrail*.rpm)

export JUNIPER_PKG_PATH="/storage/contrail/22/"
export CONTRAIL_PLUGIN_PACK_CEN_PATH=$(find ${JUNIPER_PKG_PATH} -type f -name '*rpm' )
export CONTRAIL_PLUGIN_PACK_UB_PATH=$(find ${JUNIPER_PKG_PATH} -type f -name '*deb' )


echo "Description string: ${TEST_GROUP} on ${NODE_NAME}: ${ENV_NAME}"

source $VENV_PATH/bin/activate

systest_parameters=''
[[ $USE_SNAPSHOTS == "true"  ]] && systest_parameters+=' --k' || echo new env will not be created
[[ $ERASE_AFTER  == "true"  ]] && echo the env will be erased after test || systest_parameters+=' -K' 

echo use-snapshots: $USE_SNAPSHOTS
echo venv-path: $VENV_PATH
echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH   
echo plugin-path: $DVS_PLUGIN_PATH

echo plugin path: $DVS_PLUGIN_PATH plugin checksum: $(md5sum -b $DVS_PLUGIN_PATH) 

cd plugin_test/
#./utils/jenkins/system_tests.sh -t test -w $(pwd) -j contrail.bvt.ubuntu -i $ISO_PATH  -o --group=${TEST_GROUP}

#[[ $SHUTDOWN_AFTER == "true" ]] && dos.py destroy ${ENV_NAME} || echo  the env will not be powered off after test
