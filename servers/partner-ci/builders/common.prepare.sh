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

[ -z $ISO_FILE ] && (echo "ISO_FILE variable is empty"; exit 1)

export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')

if [[ "${UPDATE_MASTER}" == "true" ]] && [[ ${FUEL_RELEASE} != *"80"* ]]; then
  [ ${SNAPSHOTS_ID} ] && export SNAPSHOTS_ID=${SNAPSHOTS_ID} || export SNAPSHOTS_ID=${CUSTOM_VERSION:10}
else
  export SNAPSHOTS_ID="released"
fi
if [[ $SNAPSHOTS_ID == *"lastSuccessfulBuild"* ]]; then
  export SNAPSHOTS_ID=$(cat snapshots.params | grep -Po '#\K[^ ]+')
fi
[ -z "${SNAPSHOTS_ID}" ] && { echo SNAPSHOTS_ID is empty; exit 1; }
#remove old logs and test data
[ -f nosetest.xml ] && rm -f nosetests.xml
[ -d logs ] && rm -rf logs/* || mkdir logs

export ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
[ ! -f $ISO_PATH ] && { echo "The $ISO_PATH isn't exist"; exit 1; }

if [[ $ISO_FILE == *"Mirantis"* ]]; then
  export FUEL_RELEASE=$(echo $ISO_FILE | cut -d- -f2 | tr -d '.iso')
fi

export REQUIRED_FREE_SPACE=200

export ENV_NAME="${ENV_PREFIX}.${SNAPSHOTS_ID}"
export VENV_PATH="${HOME}/${FUEL_RELEASE}-venv"

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

## Recreate all an virtual env
function recreate_venv {
  [ -d $VENV_PATH ] && rm -rf ${VENV_PATH} || echo "The directory ${VENV_PATH} doesn't exist"
  virtualenv --clear "${VENV_PATH}"
}

function get_venv_requirements {
  rm -f requirements.*
  wget --no-check-certificate -O requirements.txt $REQS_PATH
  export REQS_PATH="$(pwd)/requirements.txt"
  wget --no-check-certificate -O requirements-devops-source.txt $REQS_PATH_DEVOPS
  export REQS_PATH_DEVOPS="$(pwd)/requirements-devops-source.txt"
  export SPEC_REQS_PATH="${WORKSPACE}/plugin_test/requirement.txt"
}

function prepare_venv {
    source "${VENV_PATH}/bin/activate"
    easy_install -U pip
    export redirected_output='pip.properties'
    [[ "${DEBUG}" == "true" ]] && export redirected_output='/dev/null'
    pip install -r "${REQS_PATH}" --upgrade > $redirected_output || { echo "Exiting with: $?"; exit 1; }
    pip install -r "${REQS_PATH_DEVOPS}" --upgrade > $redirected_output || { echo "Exiting with: $?"; exit 1; }
    [ -e $SPEC_REQS_PATH ] && pip install -r "${SPEC_REQS_PATH}" --upgrade > $redirected_output || { echo "Exiting with: $?"; exit 1; }
    django-admin.py syncdb --settings=devops.settings --noinput
    django-admin.py migrate devops --settings=devops.settings --noinput
    deactivate
}


#################################################################
## Gets dospy environments
## with prefix the function returns all env except envs like prefix
function dospy_list {
  prefix=$1
  dos.py sync
  [ -z $prefix ] && \
    echo $(dos.py list | tail -n +3) || \
    echo $(dos.py list | tail -n +3  | grep $prefix)
}

##################################################################
[[ "${RECREATE_VENV}" == "true" ]] && recreate_venv

get_venv_requirements

[ -d $VENV_PATH ] && prepare_venv || { echo "$VENV_PATH doesn't exist $VENV_PATH will be recreated"; recreate_venv; }


source "$VENV_PATH/bin/activate"

[ -z $VIRTUAL_ENV ] && { echo "VIRTUAL_ENV is empty"; exit 1; }

if [[ "${FORCE_ERASE}" == "true" ]]; then
  for env in $(dospy_list); do
    dos.py erase $env
  done
else
  # determine free space before run the cleaner
  free_space=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)

  if (( $free_space < $REQUIRED_FREE_SPACE )); then
    for env in $(dospy_list $ENV_NAME); do
      if [[ $env  != *"released"* ]]; then
        dos.py erase $env
      fi
    done
  fi
fi
###############################################################
##############possibility of reusing envs######################
current_date=$(date +'%Y-%m-%d')
mod_current_date=$(date -d $current_date +"%Y%m%d")
for env in $(dospy_list $ENV_NAME); do
  if [[ $env  == $ENV_NAME ]]; then
    if dos.py snapshot-list $env | grep empty; then
      snap_date=$(dos.py snapshot-list $env | grep empty | awk '{print $2}')
      mod_snap_date=$(date -d $snap_date +"%Y%m%d")
      if [[ $mod_snap_date -eq $mod_current_date ]]; then
        echo "$env is suitable for test, it will be reused"
        USEFUL_ENV=$env
      else
        echo "$env is not suitable for test, it will be erased"
        dos.py erase $env
      fi
    else
      echo "there is no date-metadate, $env will be erased"
      dos.py erase $env
    fi
  else
    echo "there're no snapshots to reuse"
  fi
done

for env in $(dospy_list); do
  if [[ $env  != $USEFUL_ENV ]] && [[ $env  != *"released"* ]]; then
    dos.py erase $env
  fi
done
  ###############################################################
  # poweroff all envs
for env in $(dospy_list); do
  if [[ $env  != $USEFUL_ENV ]]; then
  dos.py destroy $env
  fi
done
