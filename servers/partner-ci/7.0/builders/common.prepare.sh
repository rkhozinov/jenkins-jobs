#!/bin/bash -e

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

# for manually run of this job
[ -z  $ISO_FILE ] && export ISO_FILE=${ISO_FILE}

#remove old logs and test data
rm -f nosetests.xml
rm -rf logs/*

export ISO_VERSION=$(cut -d'-' -f3-3<<< $ISO_FILE)
echo iso build number is $ISO_VERSION
export REQUIRED_FREE_SPACE=200
export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
export FUEL_RELEASE=$(cut -d'-' -f2-2 <<< $ISO_FILE | tr -d '.')
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

export ENV_NAME="${ENV_PREFIX}.${ISO_VERSION}"
echo iso-version: $ISO_VERSION
echo fuel-release: $FUEL_RELEASE
echo virtual-env: $VENV_PATH

## For plugins we should get a valid version of requrements of python-venv
## This requirements could be got from the github repo
## but for each branch of a plugin we should map specific branch of the fuel-qa repo
## the fuel-qa branch is determined by a fuel-iso name.

case "${FUEL_RELEASE}" in
  *80* ) export REQS_BRANCH="stable/8.0" ;;
  *70* ) export REQS_BRANCH="stable/7.0" ;;
  *61* ) export REQS_BRANCH="stable/6.1" ;;
   *   ) export REQS_BRANCH="master"
esac

REQS_PATH="https://raw.githubusercontent.com/openstack/fuel-qa/${REQS_BRANCH}/fuelweb_test/requirements.txt"

###############################################################################

## We have limited disk resources, so before run of system tests a lab
## may have many deployed and runned envs, those may cause errors during test

function delete_envs {
   [ -z $VIRTUAL_ENV ] && exit 1
   dos.py sync
   env_list=$(dos.py list | tail -n +3)
   if [[ ! -z "${env_list}" ]]; then
     for env in $env_list; do dos.py erase $env; done
   fi
}

## We have limited cpu resources, because we use two hypervisors with heavy VMs, so
## we should poweroff all unused envs, if there're exist.

function destroy_envs {
   [ -z $VIRTUAL_ENV ] && exit 1
   dos.py sync
   env_list=$(dos.py list | tail -n +3)
   if [[ ! -z "${env_list}" ]]; then
     for env in $env_list; do dos.py destroy $env; done
   fi
}

## Delete all systest envs except the env with the same version of a fuel-build
## if it exists. This behaviour is needed to use restoring from snapshots.

function delete_systest_envs {
   [ -z $VIRTUAL_ENV ] && exit 1
   dos.py sync

   for env in $(dos.py list | grep $ENV_PREFIX); do
       [[ $env == *"$ENV_NAME"* ]] && continue || dos.py erase $env
   done
}

## Recreate all an virtual env
function recreate_venv {
   [ -d $VENV_PATH ] && rm -rf ${VENV_PATH} || echo "The directory ${VENV_PATH} doesn't exist"
   virtualenv --system-site-packages "${VENV_PATH}"
}

function get_venv_requirements {
    rm -f requirements.txt*
    wget $REQS_PATH
    export REQS_PATH="$(pwd)/requirements.txt"

    # change version for some package
    if [[ "${REQS_BRANCH}" != "master" ]]; then
      # bug: https://bugs.launchpad.net/fuel/+bug/1528193
      sed -i 's/python-novaclient>=2.15.0/python-novaclient==2.35.0/' $REQS_PATH
    fi
}
   
function prepare_venv {
    source "${VENV_PATH}/bin/activate"
    pip --version
    [ $? -ne 0 ] && easy_install -U pip
    if [[ "${DEBUG}" == "true" ]]; then
        pip install -r "${REQS_PATH}" --upgrade
    else
        pip install -r "${REQS_PATH}" --upgrade > /dev/null 2>/dev/null
    fi

    django-admin.py syncdb --settings=devops.settings --noinput
    django-admin.py migrate devops --settings=devops.settings --noinput
    deactivate
}

function fix_logger {
   config_path="${HOME}/.devops/log.yaml"
   echo devops config path $config_path
   sed -i '/disable_existing_loggers.*/d' $config_path
   echo disable_existing_loggers: False >> $config_path
}


####################################################################################

[[ "${RECREATE_VENV}" == "true" ]] && recreate_venv || true

get_venv_requirements

[ -d $VENV_PATH ] && prepare_venv || exit 1

fix_logger

source "$VENV_PATH/bin/activate"

if [[ "${FORCE_ERASE}" -eq "true" ]]; then
  delete_envs
else
  # determine free space before run the cleaner
  free_space=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)

  (( $free_space < $REQUIRED_FREE_SPACE )) &&  delete_systest_envs || echo free-space: $free_space

  # poweroff all envs
  destroy_envs
fi

