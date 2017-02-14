#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

fuel_release=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
export FUEL_RELEASE=${fuel_release:?}

if [ "${SNAPSHOTS_ID}" != "released" ]; then
  if [[ "${UPDATE_MASTER}" == "true" ]] && [[ ${FUEL_RELEASE} != *"80"* ]] && [[ ${FUEL_RELEASE} != *"100"* ]]; then
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
pip freeze
cd ${WORKSPACE}/fuel-qa
sh -ex "utils/jenkins/system_tests.sh"  \
   -k                                   \
   -K                                   \
   -w "$(pwd)"                          \
   -t test                              \
   -o --group="${FUEL_QA_TEST_GROUP:?}" \
   -i ${ISO_STORAGE:?}/${ISO_FILE:?}

env_data=$(dos.py list --ips | grep ${ENV_NAME})
echo $env_data
admin_node_ip=$(echo $env_data | cut -d' ' -f2)
export NAILGUN_HOST=${NAIGLUN_HOST:-$admin_node_ip}

last_snapshot=$(dos.py snapshot-list ${ENV_NAME} | tail -1 | cut -d' ' -f1)
dos.py revert-resume ${ENV_NAME} "${last_snapshot}"


cd ${WORKSPACE}/docker/
pip install --upgrade docker-compose
ln -s ${WORKSPACE}/fuel-ui fuel-ui
docker-compose down -v
docker-compose up --remove-orphans --build --abort-on-container-exit

cd ${WORKSPACE}
cat << REPORTER_PROPERTIES > reporter.properties
ISO_VERSION=${SNAPSHOTS_ID:?}
SNAPSHOTS_ID=${SNAPSHOTS_ID:?}
ISO_FILE=${ISO_FILE:?}
TEST_GROUP=${TEST_GROUP:?}
TEST_JOB_BUILD_NUMBER=${BUILD_NUMBER:?}
TEST_JOB_NAME=${JOB_NAME:?}
DATE=$(date +'%B-%d')
REPORTER_PROPERTIES

cd ${WORKSPACE}/docker/
docker-compose ps -q | xargs docker inspect -f '{{ .State.ExitCode }}' | while read -r code; do
  if [ "$code" == "1" ]; then
    exit 1
  fi
done
