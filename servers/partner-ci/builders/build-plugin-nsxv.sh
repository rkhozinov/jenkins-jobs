#!/bin/bash
set -e

git log  --pretty=oneline | head

neutron_plugin_path="repositories/ubuntu"
old_package=$(find $neutron_plugin_path -name 'python-vmware-nsx*.deb')
[ -f $old_package ] && rm -f $old_package
new_package=$(find ./ -name 'python-vmware-nsx*.deb')
[ -f $new_package ] && mv $new_package $neutron_plugin_path || { echo "cannot find neutron plugin in ./"; exit 1; } 

path="./deployment_scripts/puppet/manifests ./deployment_scripts/puppet/modules/nsxv"

find $path -name '*.erb' -print0 | xargs -0 -P1 -L1 -I '%' erb -P -x -T '-' % | ruby -c
find $path -name '*.pp' -print0 | xargs -0 -P1 -L1 puppet parser validate --verbose
find $path -name '*.pp' -print0 | xargs -0 -r -P1 -L1 puppet-lint \
         --fail-on-warnings \
         --with-context \
         --with-filename \
         --no-80chars-check \
         --no-variable_scope-check \
         --no-nested_classes_or_defines-check \
         --no-autoloader_layout-check \
         --no-class_inherits_from_params_class-check \
         --no-documentation-check \
         --no-arrow_alignment-check

fpb --check  ./
if [[ "${DEBUG}" == "true" ]]; then
  fpb --debug --build  ./
else
  fpb --build  ./
fi
pkg_name=$(ls -t *.rpm | head -n1)
mv $pkg_name $(echo $pkg_name | head -n 1 | sed s/.noarch/-$BUILD_NUMBER.noarch/)
