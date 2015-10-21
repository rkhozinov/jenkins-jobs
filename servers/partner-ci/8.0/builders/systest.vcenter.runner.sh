#!/bin/bash
[ -z $ISO_FILE ] && export ISO_FILE=${ISO_FILE_80}
#export ISO_VERSION=`cut -d'-' -f2-3 <<< $ISO_FILE`
export ISO_VERSION=$(cat iso_version.txt)

echo iso $ISO_VERSION: $ISO_FILE
echo "ISO_FILE=${ISO_FILE}" > $properties_file
echo "ISO_VERSION=${ISO_VERSION}" >> $properties_file