#!/bin/bash

set -ex

export VENV_PATH="/home/jenkins/venv-nailgun-tests-2.9"

rm -rf "${VENV_PATH}"

REQS_PATH="${WORKSPACE}/fuel-qa/fuelweb_test/requirements.txt"

virtualenv --system-site-packages "${VENV_PATH}"
source "${VENV_PATH}/bin/activate"
pip install -r "${REQS_PATH}" --upgrade
django-admin.py syncdb --settings=devops.settings --noinput
django-admin.py migrate devops --settings=devops.settings --noinput
deactivate
