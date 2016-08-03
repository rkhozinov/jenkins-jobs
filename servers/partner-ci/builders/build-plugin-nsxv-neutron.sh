#!/bin/bash -ex

#clean
git clean -ffd

#checkout to need commit
if [ -n "$COMMIT" ]; then
git checkout $COMMIT
fi

#show commit
echo 
git log  --pretty=oneline | head
echo 

# Add debian rules from fuel-plugins-nsxv repo
NSXV_TARBALL_VERSION='master'
REPO_PATH="https://github.com/openstack/fuel-plugin-nsxv/tarball/${NSXV_TARBALL_VERSION}"
wget -qO- "$REPO_PATH" | tar --wildcards -C ./ --strip-components=2 -zxvf - "openstack-fuel-plugin-nsxv-*/vmware-nsx/"

#set changelog variables 
sed -i "s|COMMIT|$(git log -n 1 --pretty=oneline)|" debian/changelog
sed -ri "$ s|.*| -- Mirantis <tpi-ci@mirantis.com>  $(LANG=C date -R -u)|" debian/changelog


#build
fakeroot debian/rules binary

pkg_name=$(ls -t *.deb | head -n1)
mv $pkg_name $(echo $pkg_name | head -n 1 | sed s/mos0/mos0+$BUILD_NUMBER/)
