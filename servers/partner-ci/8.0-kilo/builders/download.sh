#!/bin/bash
rm *.iso || true

#JENKINS_URL="https://product-ci.infra.mirantis.net"

magneturl="$JENKINS_URL/job/$RELEASE.all/lastSuccessfulBuild/artifact/magnet_link.txt"
res=$(curl --retry 10 -sf $magneturl) || { echo "Cannot download release ISO"; exit 1; }
export $res

#VERSION=`echo $MAGNET_LINK | cut -d'-' -f2-3`
VERSION=$RELEASE
FUEL_RELEASE=$(echo $VERSION | cut -d '-' -f1 | cut -d '.' -f1-2 | sed 's/\.//g')
echo "Description string: $NODE_NAME $VERSION"

seedclient-wrapper -d -m "${MAGNET_LINK}" -v --force-set-symlink -o "${WORKSPACE}"
ISO_FILE=$(ls *iso)
echo $ISO_FILE > iso_file.txt
echo $MAGNET_LINK > magnet_link.txt
echo $VERSION > iso_version.txt

sed -i "s/ISO_FILE_${FUEL_RELEASE}.*/ISO_FILE_${FUEL_RELEASE}=${ISO_FILE}/g" latest_isos.txt || true
grep -q ISO_FILE_${FUEL_RELEASE}  latest_isos.txt || echo ISO_FILE_${FUEL_RELEASE}=${ISO_FILE} >> latest_isos.txt


