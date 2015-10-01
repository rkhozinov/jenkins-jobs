#!/bin/bash

# for manually run of this job
[ -z $ISO_FILE ] && export ISO_FILE=${ISO_FILE}  

echo venvpath: $VENV_PATH
echo isofile: $ISO_FILE
echo envprefix: $ENV_PREFIX
echo vcenter-snapshot: $VCENTER_SNAPSHOT
echo version-id: $VERSION_ID
echo openstack-release: $OPENSTACK_RELEASE

#remove old logs and test data      
rm nosetests.xml   
rm -rf logs/*      
