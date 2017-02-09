#!/bin/bash -xe
#[[ $RELEASE != '9.0-mos' ]] && { exit 1; }
rm -f *.iso || true


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
