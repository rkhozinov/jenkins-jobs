#!/bin/bash -xe
#[[ $RELEASE != '9.0-mos' ]] && { exit 1; } 
rm -f *.iso || true

JENKINS_URL="https://product-ci.infra.mirantis.net"

magneturl="$JENKINS_URL/job/$RELEASE.test_all/lastSuccessfulBuild/artifact/magnet_link.txt"
res=$(curl --retry 10 -sf $magneturl) || { echo "Cannot download release ISO"; exit 1; }
export $res

#VERSION=`echo $MAGNET_LINK | cut -d'-' -f2-3`
#VERSION=$RELEASE
#FUEL_RELEASE=`echo $VERSION j`

#seedclient-wrapper -d -m "${MAGNET_LINK}" -v --force-set-symlink -o "${WORKSPACE}"
#ISO_FILE=`ls *iso`
#echo $ISO_FILE > iso_file.txt
#echo $MAGNET_LINK > magnet_link.txt
#echo $VERSION > iso_version.txt

#sed -i "s/ISO_FILE_${FUEL_RELEASE}.*/ISO_FILE_${FUEL_RELEASE}=${ISO_FILE}/g" latest_isos.txt || true
#grep -q ISO_FILE_${FUEL_RELEASE}  latest_isos.txt || echo ISO_FILE_${FUEL_RELEASE}=${ISO_FILE} >> latest_isos.txt

VERSION=$RELEASE

FUEL_RELEASE=$(echo $VERSION | tr -d . )
echo fuel release $FUEL_RELEASE, version $VERSION
echo "Description string: $NODE_NAME $VERSION"

seedclient-wrapper -d -m "${MAGNET_LINK}" -v --force-set-symlink -o "${WORKSPACE}"
ISO_STORAGE="/srv/downloads"
ISO_FILE=$(ls *iso)
ISO_PATH="${ISO_STORAGE}/${ISO_FILE}"
if [[ $ISO_FILE == *"mos"* ]]; then
  export ISO_SYMLINK_NAME=$(echo "${ISO_FILE}" | cut -d- -f1-4)
else
  export ISO_SYMLINK_NAME=$(echo "${ISO_FILE}" | cut -d- -f1-3)
fi


ISO_SYMLINK_PATH="${ISO_STORAGE}/${ISO_SYMLINK_NAME}.iso"

[ -L $ISO_SYMLINK_PATH ] && rm -f $ISO_SYMLINK_PATH
ln -rs $ISO_PATH $ISO_SYMLINK_PATH


echo ISO_FILE=$ISO_FILE
echo ISO_FILE=$ISO_FILE > iso_file
echo ISO_VERSION=$VERSION > iso_version

# clear latest iso by release
sed -i "/ISO_FILE_${FUEL_RELEASE}.*/d" latest_isos.txt || true
echo ISO_FILE_${FUEL_RELEASE}=${ISO_FILE} >> latest_isos.txt

# ISO_FILE by default is iso for the latest fuel-release
sed -i "/ISO_FILE.*/d" latest_isos.txt || true
echo ISO_FILE=${ISO_FILE} >> latest_isos.txt
