#!/bin/bash
set -ex

export SYSTEM_TESTS="${WORKSPACE}/utils/jenkins/system_tests.sh"
export LOGS_DIR=${WORKSPACE}/logs/${BUILD_NUMBER}
export VENV_PATH='/home/jenkins/venv-nailgun-tests-2.9'
YOUR_PLUGIN_PATH="$(ls ./*rpm)" #Change this to appropriate fuel-qa variable for your plugin
export YOUR_PLUGIN_PATH         #

sh -x "${SYSTEM_TESTS}" -w "${WORKSPACE}" -V "${VENV_PATH}" -i "${ISO_PATH}" -t test -o --group="${TEST_GROUP}"
