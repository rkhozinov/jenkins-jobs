#!/bin/bash -e

git log  --pretty=oneline | head
IS_NESTED=$(cat /sys/module/kvm_intel/parameters/nested)
IS_IGNORE_MSRS=$(cat /sys/module/kvm/parameters/ignore_msrs)
IS_EPT=$(cat /sys/module/kvm_intel/parameters/ept)
echo 'nested option enable = '$IS_NESTED
echo 'ignore msrs option enable = '$IS_IGNORE_MSRS
echo 'ept option enable = '$IS_EPT
if [[ $IS_NESTED == *"Y"* ]] && [[ $IS_IGNORE_MSRS == *"Y"* ]] && [[ $IS_EPT == *"Y"* ]]; then
  echo 'nested kvm virtuallization succesfully enabled '
else
  echo 'nested kvm virtualization disabled or works incorrect, please check configuration'
fi

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x

#remove old logs and test data
[ -f nosetest.xml ] && rm -f nosetests.xml
rm -rf logs/*

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
[ ! -f $ISO_PATH ] && { echo "The $ISO_PATH isn't exist"; exit 1; }

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
  [[ "${UPDATE_MASTER}" -eq "true" ]] && export ISO_VERSION='mos-mu' || export ISO_VERSION='mos'
fi

export REQUIRED_FREE_SPACE=200
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
  *10* ) export REQS_BRANCH="stable/newton" ;;
  *90* ) export REQS_BRANCH="stable/mitaka" ;;
  *80* ) export REQS_BRANCH="stable/8.0"    ;;
  *70* ) export REQS_BRANCH="stable/7.0"    ;;
  *61* ) export REQS_BRANCH="stable/6.1"    ;;
   *   ) export REQS_BRANCH="master"
esac

REQS_PATH="https://raw.githubusercontent.com/openstack/fuel-qa/${REQS_BRANCH}/fuelweb_test/requirements.txt"

REQS_PATH_DEVOPS="https://raw.githubusercontent.com/openstack/fuel-qa/${REQS_BRANCH}/fuelweb_test/requirements-devops-source.txt"

###############################################################################

## We have limited disk resources, so before run of system tests a lab
## may have many deployed and runned envs, those may cause errors during test

function dospy {
  env_list=$2
  action=$1

  if [[ ! -z "${env_list}" ]] && [[ ! -z "${action}" ]]; then
    for env in $env_list; do dos.py $action $env; done
  fi
}

## Gets dospy environments
## with prefix the function returns all env except envs like prefix

function dospy_list {
  prefix=$1
  dos.py sync
  [ -z $prefix ] && \
    echo $(dos.py list | tail -n +3) || \
    echo $(dos.py list | tail -n +3  | grep -v $prefix)
}

## Recreate all an virtual env
function recreate_venv {
  [ -d $VENV_PATH ] && rm -rf ${VENV_PATH} || echo "The directory ${VENV_PATH} doesn't exist"
  virtualenv --clear "${VENV_PATH}"
}

function get_venv_requirements {
  rm -f requirements.*
  wget -O requirements.txt $REQS_PATH
  export REQS_PATH="$(pwd)/requirements.txt"
  wget -O requirements-devops-source.txt $REQS_PATH_DEVOPS
  export REQS_PATH_DEVOPS="$(pwd)/requirements-devops-source.txt"

  if [[ "${REQS_BRANCH}" == "stable/8.0" ]]; then
    # bug: https://bugs.launchpad.net/fuel/+bug/1528193
    #sed -i 's/@2.*/@2.9.20/g' $REQS_PATH_DEVOPS
    #echo oslo.i18n >> $REQS_PATH
    echo stable/8.0
  fi
  ## change version for some package
  #if [[ "${REQS_BRANCH}" != "master" ]]; then
  #  # bug: https://bugs.launchpad.net/fuel/+bug/1528193
  #  sed -i 's/python-novaclient>=2.15.0/python-novaclient==2.35.0/' $REQS_PATH
  #fi
}
   
function prepare_venv {
    source "${VENV_PATH}/bin/activate"
    easy_install -U pip
    if [[ "${DEBUG}" == "true" ]]; then
        pip install -r "${REQS_PATH}" --upgrade
        pip install -r "${REQS_PATH_DEVOPS}" --upgrade
    else
        pip install -r "${REQS_PATH}" --upgrade > /dev/null 2>/dev/null
        pip install -r "${REQS_PATH_DEVOPS}" --upgrade > /dev/null 2>/dev/null
    fi

    django-admin.py syncdb --settings=devops.settings --noinput
    django-admin.py migrate devops --settings=devops.settings --noinput
    deactivate
}

####################################################################################

[[ "${RECREATE_VENV}" == "true" ]] && recreate_venv

get_venv_requirements

[ -d $VENV_PATH ] && prepare_venv || { echo "$VENV_PATH doesn't exist $VENV_PATH will be recreated"; recreate_venv; }

source "$VENV_PATH/bin/activate"

[ -z $VIRTUAL_ENV ] && { echo "VIRTUAL_ENV is empty"; exit 1; }

if [[ "${FORCE_ERASE}" -eq "true" ]]; then
  for env in $(dospy_list); do 
    dos.py erase $env
  done 
else

  # determine free space before run the cleaner
  free_space=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)

  if (( $free_space < $REQUIRED_FREE_SPACE )); then 
    for env in $(dospy_list $ENV_NAME); do 
      dos.py erase $env 
    done 
  else
    echo "free-space: $free_space"
  fi
  # poweroff all envs
  for env in $(dospy_list $ENV_NAME); do 
    dos.py destroy $env 
  done 
fi
