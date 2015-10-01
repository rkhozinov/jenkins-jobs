#!/bin/bash

# for manually run of this job
[ -z  $ISO_FILE          ] && export ISO_FILE=${ISO_FILE}  
[ -z  $VENV_PATH         ] && exit 1 || echo venv-path: $VENV_PATH
[ -z  $ISO_FILE          ] && exit 1 || echo iso-file: $ISO_FILE
[ -z  $ENV_PREFIX        ] && exit 1 || echo env-prefix: $ENV_PREFIX
[ -z  $VCENTER_SNAPSHOT  ] && exit 1 || echo vcenter-snapshot: $VCENTER_SNAPSHOT 
[ -z  $FUEL_RELEASE      ] && exit 1 || echo fuel-release: $FUEL_RELEASE
[ -z  $OPENSTACK_RELEASE ] && exit 1 || echo openstack-release: $OPENSTACK_RELEASE
[ -z  $ISO_STORAGE       ] && exit 1 || echo iso-storage: $ISO_STORAGE
[ -z  $NODES_COUNT       ] && exit 1 || echo nodes-count: $NODES_COUNT
[ -z  $TEST_GROUP        ] && exit 1 || echo test-gorup: $TEST_GROUP
[ -z  $USE_SNAPSHOTS     ] && exit 1 || echo use-snapshots: $USE_SNAPSHOTS
[ -z  $SHUTDOWN_AFTER    ] && exit 1 || echo shutdown-after: $SHUTDOWN_AFTER
[ -z  $ERASE_AFTER       ] && exit 1 || echo erase-after: $ERASE_AFTER

#remove old logs and test data      
rm -f nosetests.xml   
rm -rf logs/*      

export VENV="$VENV_PATH/bin/activate"
export ENV_NAME="${ENV_PREFIX}_$ISO_VERSION"
export REQUIRED_FREE_SPACE=200
export ISO_PATH="$ISO_STORAGE/$ISO_FILE"

echo env-name: $ENV_NAME
echo iso-path: $ISO_PATH

systest_parameters=''
[ $USE_SNAPSHOTS  ] && systest_parameters+=' --existing'
[ $SHUTDOWN_AFTER ] && systest_parameters+=' --destroy'
[ $ERASE_AFTER    ] && systest_parameters+=' --erase'

echo systest-params: $systest_parameters
###############################################################################

## We have limited disk resources, so before run of system tests a lab
## may have many deployed and runned envs, those may cause errors during test

function delete_envs {
    dos.py sync
    for env in $(dos.py list | tail -n +3) ; do dos.py erase $env; done
}

## We have limited cpu resources, because we use two hypervisors with heavy VMs, so
## we should poweroff all unused envs, if there're exist. 

function destroy_envs {
    dos.py sync
    for env in $(dos.py list | tail -n +3); do dos.py destroy $env; done
}

## Delete all systest envs except the env with the same version of a fuel-build 
## if it exists. This behaviour is needed to use restoring from snapshots.

function delete_systest_envs {
   dos.py sync 
   for env in $(dos.py list | tail -n +3 | grep $ENV_PREFIX); do
       [[ $env == *"$ENV_NAME"* ]] && continue || dos.py erase $env
   done
}

####################################################################################

# determine free space before run the cleaner
free_space_exist=false
free_space=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)

(( $free_space > $REQUIRED_FREE_SPACE )) && export free_space_exist=true 

# activate a python virtual env#
source $VENV 

# free space
#[ $free_space_exist ] && delete_systest_envs || delete_envs 
#
## poweroff all envs
#destroy_envs

# TODO: add test run
echo "Description string: ${TEST_GROUP} on ${NODE_NAME}: ${ENV_NAME}"

#bash -x /btsync/tpi_systest.sh -i $ISO_PATH -d $OPENSTACK_RELEASE -t $TEST_GROUP -n $NODES_COUNT $systest_parameters
dos.py list | tail -n +3

# deactivate the python virtual env
deactivate

