#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

. "${VENV_PATH}/bin/activate"
cd ${WORKSPACE}/fuel-qa
sh -ex "utils/jenkins/system_tests.sh"  \
   -k                                   \
   -K                                   \
   -w "$(pwd)"                          \
   -t test                              \
   -o --group="${TEST_GROUP:?}" \
   -i ${ISO_STORAGE:?}/${ISO_FILE:?}

env_data=$(dos.py list --ips | grep ${ENV_NAME})
echo $env_data
admin_node_ip=$(echo $env_data | cut -d' ' -f2)
export NAILGUN_HOST=${NAIGLUN_HOST:-$admin_node_ip}

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
