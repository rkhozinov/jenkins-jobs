#!/bin/bash -e
export TESTRAIL_USER=$TREP_TESTRAIL_USER
export TESTRAIL_API_KEY=$TREP_TESTRAIL_PASSWORD
RST2TR_HOME="${WORKSPACE}/rst2tr"
PATH_TO_DOCS="${WORKSPACE}/fuel-plugin-contrail/doc/testing/"
cd $RST2TR_HOME
if [ "${MODERN_MODEL}" == "true" ] && MODEL="$RST2TR_HOME/formats/modern_model.yaml" || MODEL="$RST2TR_HOME/formats/classic_model.yaml"
if [[ "${CHECK_ONLY}" == "true" ]]; then
  python $RST2TR_HOME/rst2tr/rst2tr.py -f $MODEL -v -s -n ${PATH_TO_DOCS}
else
  python $RST2TR_HOME/rst2tr/rst2tr.py -f $MODEL -v -s ${PATH_TO_DOCS}
