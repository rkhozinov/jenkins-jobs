#!/bin/bash
[ -z $ISO_FILE ] && export ISO_FILE=${ISO_FILE_70}
export ISO_VERSION=`cut -d'-' -f2-3 <<< $ISO_FILE`

echo iso $ISO_VERSION: $ISO_FILE
echo "ISO_FILE=${ISO_FILE}" > $properties_file
echo "ISO_VERSION=${ISO_VERSION}" >> $properties_file
