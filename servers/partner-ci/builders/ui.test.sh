#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

fuel_release=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
export FUEL_RELEASE=${fuel_release:?}

if [ "${SNAPSHOTS_ID}" != "released" ]; then
  if [[ "${UPDATE_MASTER}" == "true" ]] && [[ ${FUEL_RELEASE} != *"80"* ]]; then
      . $SNAPSHOT_OUTPUT_FILE
      export EXTRA_RPM_REPOS
      export UPDATE_FUEL_MIRROR
      export EXTRA_DEB_REPOS
  else
    export SNAPSHOTS_ID="released"
  fi
fi

[[ $SNAPSHOTS_ID == *"lastSuccessfulBuild"* ]] && \
  export SNAPSHOTS_ID=$(grep -Po '#\K[^ ]+' < snapshots.params)

export ENV_NAME="${ENV_PREFIX:?}.${SNAPSHOTS_ID:?}"
export VENV_PATH="${HOME}/${FUEL_RELEASE:?}-venv"

. "${VENV_PATH}/bin/activate"

cd fuel-qa
bash -x "./utils/jenkins/system_tests.sh" \
   -k                                     \
   -K                                     \
   -V ${VENV_PATH}                        \
   -w $(pwd)                              \
   -t test                                \
   -o --group="${FUEL_QA_TEST_GROUP:?}"   \
   -i ${ISO_FILE:?}

echo "ENVIRONMENT NAME is $ENV_NAME"
dos.py list --ips | grep ${ENV_NAME}

#remove old logs and test data
[ -f nosetest.xml ] && sudo rm -f nosetests.xml
sudo rm -rf logs/*
