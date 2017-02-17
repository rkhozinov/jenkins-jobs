#!/bin/bash -e
# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

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
