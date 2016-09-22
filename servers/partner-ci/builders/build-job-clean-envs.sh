#####################################################################
function dospy_list {
  prefix=$1
  dos.py sync
  [ -z $prefix ] && \
    echo $(dos.py list | tail -n +3) || \
    echo $(dos.py list | tail -n +3  | grep  $prefix)
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

for env in $(dospy_list); do
  dos.py erase $env
done
