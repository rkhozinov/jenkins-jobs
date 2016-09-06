#####################################################################
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
######################################################################

export REQUIRED_FREE_SPACE=200
#export VENV_PATH="${HOME}/${FUEL_RELEASE_NUMBER}-venv"
if source "${HOME}/${FUEL_RELEASE_NUMBER}-venv/bin/activate"; then
  echo "${FUEL_RELEASE_NUMBER}-venv has been successfully activated"
else
  echo "there is no venv named ${FUEL_RELEASE_NUMBER}, switched to 90 (default)"
  source "${HOME}/90-venv/bin/activate"
fi

if [[ "${FORCE_ERASE}" -eq "true" ]]; then
  for env in $(dospy_list); do
    if [[ $env  != *"released"* ]]; then
      dos.py erase $env
    fi  
  done
fi

free_space_2nd_check=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)
if (( $free_space_2nd_check < $REQUIRED_FREE_SPACE )); then 
  for env in $(dospy_list); do 
    dos.py erase $env
  done 
else
  echo "free-space: $free_space_2nd_check"
fi 

    
