#!/usr/bin/env bash
set -x
venv_path='/home/jenkins/ui-rep'
[ -d $venv_path ] && source $venv_path/bin/activate || (echo an venv is needed; virtualenv $venv_path -p /usr/bin/python2.7)
source $venv_path/bin/activate
pip install -r requirements.txt --upgrade
python reporter.py
