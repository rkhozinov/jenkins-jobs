#!/bin/bash
rm -f nosetests.xml
rm -rf logs/*

[ -z $ISO_FILE ] && export ISO_FILE=${ISO_FILE_80}
export ISO_VERSION=`cut -d'-' -f2-3 <<< $ISO_FILE`

echo iso file is $ISO_FILE
echo iso version is $ISO_VERSION

## determine free space before run the cleaner
FREE_SPACE_EXIST=false
free_space=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)

(( $free_space > 100 )) && export FREE_SPACE_EXIST=true 

source $VENV_PATH/bin/activate
env_list=$(dos.py list | tail -n +3)
env_systest_list=$(echo $env_list | grep $ENV_PREFIX)

for env_systest in $env_systest_list; do
   
	
    

#dev=`lsblk -l | grep / | awk '{print $1}'`
#used_space=`df -h | grep $dev | awk '{print $3}'
#free_space=`df -h | grep $dev | awk '{print $3}'`
#echo disk $dev free space $free_space

