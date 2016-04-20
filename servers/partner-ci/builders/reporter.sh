#!/usr/bin/env bash
venv_path='/home/jenkins/trep'
[ -d $venv_path ] && source $venv_path/bin/activate || (echo an venv is needed; exit 1)
python setup.py install > /dev/null 2>/dev/null



env
trep