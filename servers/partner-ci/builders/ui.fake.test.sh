#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

VENV_PATH='home/jenkins/fake-venv'
function prepare_venv {
    source "${VENV_PATH}/bin/activate"
    easy_install -U pip
    pip install --upgrade docker-compose
    deactivate
}


if [[ "${RECREATE_VENV}" == "true" ]] || [[ ! -d ${VENV_PATH:?} ]]; then
  virtualenv --clear "${VENV_PATH}"
fi

prepare_venv

export TEST_PATH="${TEST_PREFIX:?}/${TEST_GROUP:?}.js"

. "${VENV_PATH}/bin/activate"
cd ${WORKSPACE}/docker/

if ln -s ${WORKSPACE}/docker/fuel-web fuel-web; then
  echo "symlink to fuel-web created"
else
  echo "symlink to fuel-web already exists"
fi
docker-compose down -v
docker-compose up --remove-orphans --build --abort-on-container-exit

cd ${WORKSPACE}
cat << REPORTER_PROPERTIES > reporter.properties
TEST_GROUP=${TEST_GROUP}
TEST_PATH=${TEST_PATH:?}
TEST_PREFIX=${TEST_PREFIX}
TEST_JOB_BUILD_NUMBER=${BUILD_NUMBER:?}
TEST_JOB_NAME=${JOB_NAME:?}
DATE=${COMMON_DATE:=$(date +'%D %T %Z')}
REPORTER_PROPERTIES

cd ${WORKSPACE}/docker/
docker-compose ps -q | xargs docker inspect -f '{{ .State.ExitCode }}' | while read -r code; do
  if [ "$code" == "1" ]; then
    exit 1
  fi
done
