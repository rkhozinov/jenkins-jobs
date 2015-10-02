#!/bin/bash -ex 
# for manually run of this job
[ -z  $ISO_FILE          ] && export ISO_FILE=${ISO_FILE}  

#remove old logs and test data      
rm -f nosetests.xml   
rm -rf logs/*      

export ISO_VERSION=$(cut -d'-' -f3-3 <<< $ISO_FILE)
export REQUIRED_FREE_SPACE=200
export ISO_PATH="$ISO_STORAGE/$ISO_FILE"


###############################################################################

## We have limited disk resources, so before run of system tests a lab
## may have many deployed and runned envs, those may cause errors during test

function delete_envs {
   [ -z $VIRTUAL_ENV ] && exit 1
   dos.py sync
   for env in $(dos.py list | tail -n +3) ; do dos.py erase $env; done
}

## We have limited cpu resources, because we use two hypervisors with heavy VMs, so
## we should poweroff all unused envs, if there're exist. 

function destroy_envs {
   [ -z $VIRTUAL_ENV ] && exit 1
   dos.py sync
   for env in $(dos.py list | tail -n +3); do dos.py destroy $env; done
}

## Delete all systest envs except the env with the same version of a fuel-build 
## if it exists. This behaviour is needed to use restoring from snapshots.

function delete_systest_envs {
   [ -z $VIRTUAL_ENV ] && exit 1
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

# activate a python virtual env
source "$VENV_PATH/bin/activate" 

# free space
[ $free_space_exist ] && delete_systest_envs || delete_envs 

# poweroff all envs
destroy_envs
