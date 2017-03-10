#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

. "${VENV_PATH}/bin/activate"
cd ${WORKSPACE}/docker/
pip install --upgrade docker-compose
ln -s ${WORKSPACE}/docker/fuel-web fuel-web
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
