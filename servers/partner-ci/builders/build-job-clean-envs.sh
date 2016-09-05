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
source "$VENV_PATH/bin/activate"

[ -z $VIRTUAL_ENV ] && { echo "VIRTUAL_ENV is empty"; exit 1; }

if [[ "${FORCE_ERASE}" -eq "true" ]]; then
  for env in $(dospy_list); do
    if [[ $env  != *"released"* ]]; then
      dos.py erase $env
    fi  
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
export REQUIRED_FREE_SPACE=300
free_space_2nd_check=$(df -h | grep '/$' | awk '{print $4}' | tr -d G)
 if (( $free_space_2nd_check < $REQUIRED_FREE_SPACE )); then 
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
