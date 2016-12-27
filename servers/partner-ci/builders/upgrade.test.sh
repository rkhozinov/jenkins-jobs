#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

export ISO_PATH=${ISO_PATH:-"$ISO_STORAGE/$ISO_FILE"}
export MOS_UBUNTU_MIRROR_ID=$(grep "^MOS_UBUNTU_MIRROR_ID" < snapshots.params | cut -d= -f2)
export MOS_CENTOS_PROPOSED_MIRROR_ID=$(grep "^MOS_CENTOS_PROPOSED_MIRROR_ID" < snapshots.params | cut -d= -f2)

fuel_release=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
export FUEL_RELEASE=$fuel_release

if [ "${SNAPSHOTS_ID}" != "released" ]; then
  if [[ "${UPDATE_MASTER}" == "true" ]] && [[ ${FUEL_RELEASE} != *"80"* ]]; then
    if [ -f $SNAPSHOT_OUTPUT_FILE ]; then
      . $SNAPSHOT_OUTPUT_FILE
      export EXTRA_RPM_REPOS
      export UPDATE_FUEL_MIRROR
      export EXTRA_DEB_REPOS
    else
      echo "SNAPSHOT_OUTPUT_FILE is empty or doesn't exist"
      exit 1
    fi
  else
    export SNAPSHOTS_ID="released"
  fi
fi

[[ $SNAPSHOTS_ID == *"lastSuccessfulBuild"* ]] && \
  export SNAPSHOTS_ID=$(grep -Po '#\K[^ ]+' < snapshots.params)

#remove old logs and test data
[ -f nosetest.xml ] && sudo rm -f nosetests.xml
sudo rm -rf logs/*

export ENV_NAME="${ENV_PREFIX:?}.${SNAPSHOTS_ID:?}"
export VENV_PATH="${HOME}/${FUEL_RELEASE:?}-venv"


. "${VENV_PATH}/bin/activate"

sh -x "utils/jenkins/system_tests.sh" \
   -k                                 \
   -K                                 \
   -w "$WORKSPACE"                    \
   -t test                            \
   -o --group="${TEST_GROUP}"         \
   -i ${ISO_PATH:?}

echo "ENVIRONMENT NAME is $ENV_NAME"
dos.py list --ips | grep ${ENV_NAME}
