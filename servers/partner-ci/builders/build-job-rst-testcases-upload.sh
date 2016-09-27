#!/bin/bash -e
source /home/jenkins/90-venv/bin/activate
HOME="/home/jenkins"
RST2TR_HOME="/home/jenkins/rst2tr"
CONTRAIL_HOME="/home/jenkins/fuel-plugin-contrail"
PATH_TO_DOCS="$CONTRAIL_HOME/doc/testing/"
if [ "$(ls -A /home/jenkins/fuel-plugin-contrail)" ]; then
  echo "fuel-plugin-repo exists"
  cd $CONTRAIL_HOME
  git pull
else
  echo "need to upload repo"
  cd /home/jenkins
  git clone https://github.com/openstack/fuel-plugin-contrail.git
fi
if [ "$(ls -A /home/jenkins/rst2tr)" ]; then
  echo "program exists"
  cd $RST2TR_HOME
  git pull
else
  echo "need to upload repo"
  cd $HOME
  git clone https://github.com/ehles/rst2tr.git
fi
cd $RST2TR_HOME
if [ "${MODERN_MODEL}" == "true" ] && MODEL="$RST2TR_HOME/formats/modern_model.yaml" || MODEL="$RST2TR_HOME/formats/classic_model.yaml"
if [[ "${CHECK_ONLY}" == "true" ]]; then	
  $RST2TR_HOME/rst2tr/rst2tr.py -f $MODEL -v -s -n ${PATH_TO_DOCS}
else
  $RST2TR_HOME/rst2tr/rst2tr.py -f $MODEL -v -s ${PATH_TO_DOCS}
