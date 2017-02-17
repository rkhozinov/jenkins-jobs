#!/bin/bash -xe

rm -f *.iso || true

VERSION=$RELEASE
FUEL_RELEASE=$(echo $VERSION | tr -d . )

echo fuel release $FUEL_RELEASE, version $VERSION
echo "Description string: $NODE_NAME $VERSION"

ISO_STORAGE="/storage/downloads"
aria2c --seed-time 0 "${MAGNET_LINK}" -d "${WORKSPACE}"
ISO_FILE=$(ls *.iso)
ISO_PATH="${ISO_STORAGE}/${ISO_FILE:?}"
cut_params="cut -d- -f1-3"
[[ $ISO_FILE == *"mos"* ]] && cut_params="cut -d- -f1-4"

sudo mv $ISO_FILE $ISO_PATH
export ISO_SYMLINK_NAME=$(echo "${ISO_FILE}" | $cut_params)

ISO_SYMLINK_PATH="${ISO_STORAGE}/${ISO_SYMLINK_NAME}.iso"

[ -L $ISO_SYMLINK_PATH ] && rm -f $ISO_SYMLINK_PATH
sudo ln -rs $ISO_PATH $ISO_SYMLINK_PATH

echo "ISO_FILE=$ISO_FILE"   | tee -i iso_file
echo "ISO_VERSION=$VERSION" | tee -i iso_version
