#!/bin/bash
#echo $VENV_PATH
#rm old logs
rm nosetests.xml
rm -rf logs/*

[ -z $ISO_FILE ] && export ISO_FILE=${ISO_FILE_80}
export ISO_VERSION=`cut -d'-' -f2-3 <<< $ISO_FILE`

echo iso $ISO_VERSION: $ISO_FILE
echo "$ISO_FILE=${ISO_FILE}" > $properties_file
echo "$ISO_VERSION=${ISO_VERSION}" >> $properties_file


#    echo iso $ISO_VERSION: $ISO_FILE
#    echo $ISO_FILE > iso_file.txt;
#    echo $ISO_VERSION > iso_version.txt;
#
#
#    # check if job for this magnet link already was successful
#    # cannot use copy artifacts here as for now it doesn't escape
#    #LAST_SUCCESS_MAGNET_LINK=`curl -sf $JOB_URL/lastSuccessfulBuild/artifact/magnet_link.txt`
#    LAST_SUCCESS_ISO_VERSION=`curl -sf $JOB_URL/lastSuccessfulBuild/artifact/iso_version.txt`
#
#    #[ "$MAGNET_LINK" = "$LAST_SUCCESS_MAGNET_LINK" ] && 
#    [ -z $REPEAT_SUCCESFUL ] && [ "$ISO_VERSION" = "$LAST_SUCCESS_ISO_VERSION" ] &&
#        { echo "Description string: test for $ISO_VERSION succeeded already, skipping";
#              exit 0; 
#          }
#
#          iso_path="/storage/downloads/$ISO_FILE"
#          export ENV_NAME=nightly_vcenter_systest_${ISO_VERSION}
#
#          source $VENV_PATH/bin/activate
#          export EXT_SNAPSHOT=vcenterha
#
#
#          echo "Description string: ${TEST_GROUP} on ${NODE_NAME}: ${ENV_NAME}"
#          bash -x "/btsync/tpi_jenkins.sh" $iso_path --existing
#
#
