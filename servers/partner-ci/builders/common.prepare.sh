#!/bin/bash -e

# check kvm virtualization status
echo "nested option enable = $(cat /sys/module/kvm_intel/parameters/nested)"
echo "ignore msrs option enable = $(cat /sys/module/kvm/parameters/ignore_msrs)"
echo "ept option enable = $(cat /sys/module/kvm_intel/parameters/ept)"

# activate bash xtrace for script
[[ "${DEBUG}" == "true" ]] && set -x || set +x


# preparing workspace
[ -d logs ] && rm -rf logs/* || mkdir logs
test -d ${VENV_PATH:?} || virtualenv --clear "${VENV_PATH}"

REQS_PATH="https://raw.githubusercontent.com/openstack/fuel-qa/${REQS_BRANCH:?}/fuelweb_test/requirements.txt"
REQS_PATH_DEVOPS="https://raw.githubusercontent.com/openstack/fuel-qa/${REQS_BRANCH}/fuelweb_test/requirements-devops-source.txt"


## Recreate all an virtual env
function recreate_venv {
  [ -d $VENV_PATH ] && rm -rf ${VENV_PATH}
  virtualenv --clear "${VENV_PATH}"
}

function get_venv_requirements {
  rm -f requirements.*
  wget --no-check-certificate -O requirements.txt $REQS_PATH
  export REQS_PATH="$(pwd)/requirements.txt"
  wget --no-check-certificate -O requirements-devops-source.txt $REQS_PATH_DEVOPS
  export REQS_PATH_DEVOPS="$(pwd)/requirements-devops-source.txt"
  export SPEC_REQS_PATH="${WORKSPACE}/plugin_test/requirement.txt"
  sed -i 's/2.9.23/release\/2.9/g' $REQS_PATH_DEVOPS
  # additional libraries associated with vcenter-control wrapper
  echo -e "pyvim\npyvmomi" >> $REQS_PATH
}

function prepare_venv {
    source "${VENV_PATH}/bin/activate"
    easy_install -U pip
    export redirected_output='pip.properties'
    pip install -r "${REQS_PATH}" --upgrade > $redirected_output
    pip install -r "${REQS_PATH_DEVOPS}" --upgrade > $redirected_output
    [ -e $SPEC_REQS_PATH ] && pip install -r "${SPEC_REQS_PATH}" --upgrade > $redirected_output
    django-admin.py syncdb --settings=devops.settings --noinput
    django-admin.py migrate devops --settings=devops.settings --noinput
    deactivate
}

function smart_erase {
  env=$1

  virsh list --all --name | grep $env && vms=$(virsh list --all --name | grep $env) || echo "there is no vms"

  virsh net-list | tail -n +3 | cut -d' ' -f2-2 | grep $env && networks=$(virsh net-list | tail -n +3 | cut -d' ' -f2-2 | grep $env) \
  || echo "there is no networks"
  if [ ! -z "$networks" ]; then
    for net in $networks; do
      if virsh net-destroy $net; then
        echo "network destroyed succesfully"
      else
        ref=$?
        echo "there are some troubles with virt-networks stack, please check ( exit code = $ref )"
      fi
      if virsh net-undefine $net; then
        echo "network destroyed succesfully"
      else
        ref=$?
        echo "there are some troubles with virt-networks stack, please check ( exit code = $ref )"
      fi
    done
  fi
  if [ ! -z "$vms" ]; then
    for vm in $vms; do
      if virsh domstate $vm | grep -e '.*shut.*' -q; then
        if virsh destroy $vm; then
          echo "domain destroyed succesfully"
          virsh undefine --remove-all-storage --snapshots-metadata $vm
        else
          ref=$?
          echo "there are some troubles with virt stack, restart services and recheck"
          sudo service libvirt-bin restart
          if virsh destroy $vm; then
            echo "domain destroyed succesfully"
            virsh undefine --remove-all-storage --snapshots-metadata $vm
          else
            ref=$?
            echo "there are some troubles with virt stack, please check it manually "
          fi
        fi
      else
        virsh undefine --remove-all-storage --snapshots-metadata $vm
      fi
    done
  fi
  dos.py sync
}

## Gets dospy environments
## with prefix the function returns all env except envs like prefix
function dospy_list {
  prefix=$1
  dos.py sync
  [ -z $prefix ] && \
    dos.py list | tail -n +3 || \
    dos.py list | tail -n +3 | grep $prefix
}

if [[ "${RECREATE_VENV}" == "true" ]]; then
  recreate_venv
  get_venv_requirements
  [ -d $VENV_PATH ] && prepare_venv
fi

source "$VENV_PATH/bin/activate" && echo ${VIRTUAL_ENV:?}


if [[ "${FORCE_REUSE}" == "false" ]]; then
  if [[ "${FORCE_ERASE}" == "true" ]]; then
    for env in $(dospy_list); do
#      smart_erase $env
      dos.py erase $env
    done
  else
    # determine free space before run the cleaner
    free_space=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)

    if (( free_space < REQUIRED_FREE_SPACE )); then
      for env in $(dospy_list $ENV_NAME); do
        if [[ $env  != *"released"* ]]; then
#      smart_erase $env
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
    if [[ "$env"  == "$ENV_NAME" ]] && [[ "$env"  != *"released"* ]]; then
      if [[ "$env"  != *"released"* ]]; then
        if dos.py snapshot-list $env | grep "empty"; then
          snap_date=$(dos.py snapshot-list $env | grep empty | awk '{print $2}')
          mod_snap_date=$(date -d $snap_date +"%Y%m%d")
          if [[ $mod_snap_date -eq $mod_current_date ]]; then
            echo "$env is suitable for test, it will be reused"
            USEFUL_ENV=$env
          else
            echo "$env is not suitable for test, it will be erased"
#            smart_erase $env
            dos.py erase $env
          fi
        else
          echo "there is no date-metadata, $env will be erased"
#          smart_erase $env
          dos.py erase $env
        fi
      else
        echo "there're no snapshots to reuse"
      fi
    fi
  done

  for env in $(dospy_list); do
    if [[ "$env"  != "$USEFUL_ENV" ]] && [[ $env  != *"released"* ]]; then
#      smart_erase $env
      dos.py erase $env
    fi
  done
fi
