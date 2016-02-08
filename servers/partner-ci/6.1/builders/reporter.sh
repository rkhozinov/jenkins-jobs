#!/usr/bin/env bash
ls -al
pwd
venv_path='/home/jenkins/trep'
[ -d $venv_path ] && source $venv_path/bin/activate
python setup.py install
ls -al
trep